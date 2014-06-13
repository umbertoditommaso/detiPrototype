require 'nokogiri'
class TasksController < ApplicationController


  def start
    @task = Task.find(params[:id])
    root = Dir.pwd
    File.open("#{@task.path}/#{@task.exec}.xml","w"){|f| f.write @task.settings.to_xml(:root=>"settings")}
    #Dir.chdir(@task.path)
    puts "[TASK_CONTOLLER]executing task:#{@task.getCmd(root)} \n"
    puts "[TASK_CONTROLLER]Working Directory:#{@task.path} \n"
    #the task is started throught a ruby script launcher so it can switch to the required working path
    #without changing the rails app settings
    @cmd ="ruby proc/launch.rb #{@task.path} \"#{@task.getCmd(root)}\""
    #puts @cmd
    @pid = Process.spawn(@cmd) unless @scheduled
    puts "[TASK_CONTROLLER]Task launched,pid:#{@pid} \n"
    @task.update_attribute(:finalized,false)
    @task.acquire_locks
    respond_to do |format|
      format.html {redirect_to tasks_url}
      format.json { render json: {task:@task,pid:@pid} }
    end
  end

  #POST tasks/purge
  # *delete all task finalized and their stdout files
  def purge
    @tasks =Task.where("finalized = 't'")
    @tasks.destroy_all
    respond_to do |format|
      format.html {redirect_to tasks_url}
      format.json { render json: @task }
    end
  end

  #GET tasks/not_finalized
  #GET tasks/not_finalized.json
  # *return a list of not finalized tasks
  def not_finalized
    @tasks = Task.where("finalized != 't'")
    respond_to do |format|
      format.html {render 'index'}
      format.json { render json: @tasks }
    end
  end

  #POST tasks/:id/finalize.js
  # *finalize the task
  # => execute all the after command associated with the task
  # => render, if exists, a javascript file associated with the task
  # => save the task as finalized
  def finalize#(task)
    Task.transaction do
      task = Task.find(params[:id])
      f = File.open(task.getManifest)
      @doc = Nokogiri::XML(f)
      root = Dir.pwd
      @rubies=@doc.xpath("//after//ruby")
      @evals =[]
      @doc.xpath("//after//eval").each do |node|
        @evals << node.content
      end
      if @rubies then
        @rubies.each do |script|
          res = Process.spawn("ruby \"#{root}/#{script.content}\"")
        end
      end
      if@evals then
        @evals.each do |script|     
          res =eval(script)
        end
      end
      @script = @doc.at_css("after render js")
      if @script then
        @script = @script.content
      else
        @script = "success"
      end
      f.close
      task.locks.destroy_all
      task.finalized = true
      task.save!
      respond_to do |format|
          format.html {redirect_to not_finalized_tasks_url}
          format.js { render @script}
      end
    end
  end


  

  def schedule
    #f = File.open("proc/schedule.xml")
    #@doc = Nokogiri::XML(f)
    #@parser = @doc.xpath("//task")
    #@tasks = []
    #@parser.xpath("//id").each do |id|
    #  @tasks << Task.find(id.content)
    #end
    @tasks = Task.where("finalized IS NULL")
    respond_to do |format|
      format.html 
      format.json{render json:@tasks}
      format.xml{render xml:@doc}
    end
  end

  #POST /tasks/init
  # => Build a task object from the given parameters
  # => execute the commands associated with the <before> tag in the task's manifest file
  # => persist in the database the task object
  # => run the task command throught a launcher script
  def init
    Task.transaction do
      @task = Task.new
      @task.finalized = false
      @task.name_id = params[:task][:name_id]
      @task.arguments = ""
      @task.inputs= params[:task][:inputs]
      @task.settings = params[:task][:settings]
      @task.arguments = ""
      #the inputs value are appendend in the arguments string
      if @task.inputs then
        @task.inputs.each do |name,value| 
          @task.arguments << " " + value
        end
      end
      #open the task manifest
      f = File.open(@task.getManifest)
      #parse using Nokigiri gem
      doc = Nokogiri::XML(f)
      #recove executable name and working path
      @task.exec = doc.at_css("executable name").content
      @task.path = Dir.pwd+doc.at_css("workingDir").content    
      
      #execute the before commands
      doc.xpath("//before//eval").each do |script|
        puts "[TASK_CONTOLLER]executing script:#{script.content}"
        eval(script.content)#execute the string as a run-time ruby code
      end

      @task.settings.each do |key,value|#parse the settings
        #switch every the occurrence of token $(name) with the 
        #the value of the settings hash with the name as key 
        while @task.path.include?("$(#{key})") do
          @task.path["$(#{key})"] = value
        end
        while @task.exec.include?("$(#{key})") do
          @task.exec["$(#{key})"] = value
        end
      end
      f.close
      @task.save!
      if params[:schedule] then
        @scheduled = true
        f = File.open("proc/schedule.xml")
        @doc = Nokogiri::XML(f)
        root = @doc.at_css("tasks")
        #task = Nokogiri::XML::Node.new "task", @doc
        node = @task.to_xml(skip_instruct: true)
        root.add_child(node)
        f.close        
        File.open("proc/schedule.xml","w"){|f| f.write @doc.to_xml}
        @script = "tasks/added_schedule"
        @task.update_attribute(:finalized,nil)
      else  
        Lock.transaction do
          #open the task manifest
          f = File.open(@task.getManifest)
          #parse using Nokigiri gem
          doc = Nokogiri::XML(f)
          if check_proc_is_running @task.exec then
            raise ActiveRecord::Rollback, "This program is already been locked"
          end
          lock = Lock.acquire(@task.exec,'x')
          raise ActiveRecord::Rollback, "Resourse locked by another task" unless lock
          @task.locks << lock
        #  
          doc.xpath("//inputs//files").each do |entry|
            lock = Lock.acquire( @task.path+entry.content,'r')
            raise ActiveRecord::Rollback, "Resourse locked by another task" unless lock
            @task.locks << lock
          end
          doc.xpath("//output//files").each do |entry| 
            lock = Lock.acquire(@task.path+entry.content,'w')
            raise ActiveRecord::Rollback, "Resourse locked by another task" unless lock
            @task.locks << lock
          end
          f.close
          @task.save!
        end
        @script = "tasks/init"
      end
      respond_to do |format|
          root = Dir.pwd
          File.open("#{@task.path}/#{@task.exec}.xml","w"){|f| f.write @task.settings.to_xml(:root=>"settings")}
          #Dir.chdir(@task.path)
          puts @task.getCmd(root)
          puts @task.path
          #the task is started throught a ruby script launcher so it can switch to the required working path
          #without changing the rails app settings
          @cmd ="ruby proc/launch.rb #{@task.path} \"#{@task.getCmd(root)}\""
          puts @cmd
          @pid = Process.spawn(@cmd) unless @scheduled
          puts @pid
          #Process.spawn(@cmd)
          puts "[TASK_CONTROLLER]Rendering:#{@script}"
          format.html { redirect_to status_task_url,@task, notice: 'Task was successfully created.'}
          format.js { render @script}
          format.json { render json: @task, status: :created, location: @task }
      end
    end
  end

  

  #GET /tasks/status?:id
  #GET /tasks/status?:id.json
  #GET /tasks/status?:id.xml
  # => check if the task is still running(windows only)
  # => retrive the current task stdout
  def status
    @task = Task.find(params[:id])
    @running = check_proc_is_running @task.exec
    @output =""
    
    #open the stdout file
    file = File.new("#{@task.getStdout}","r")
    while (line = file.gets)
      @output += line +"\n"#append the line to the output var
    end
    file.close
    @status ={task:@task,output:@output,running:@running}#create an hash with the require objects
    respond_to do |format|
      format.html
      format.js
      format.json {render json:@status} 
      format.xml  {render xml:@status}
    end 
  end



  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = Task.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    @task = Task.find(params[:id])
    #@output=""
    #file = File.new("#{@task.getStdout}","r")
    #while (line = file.gets)
    #  @output += line +"\n"
    #end
    #file.close
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.json
  def new
    @task = Task.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = Task.find(params[:id])
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(params[:task])

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: 'Task was successfully created.' }
        format.js
        format.json { render json: @task, status: :created, location: @task }
      else
        format.html { render action: "new" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.json
  def update
    @task = Task.find(params[:id])

    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task = Task.find(params[:id])
    File.delete(@task.getStdout) unless !File.exists?(@task.getStdout)
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url }
      format.json { head :no_content }
    end
  end

  protected
  
  def acquire_locks(task)
    Lock.transaction do
      #open the task manifest
      f = File.open(task.getManifest)
      #parse using Nokigiri gem
      doc = Nokogiri::XML(f)
      if check_proc_is_running task.exec then
        raise ActiveRecord::Rollback, "This program is already been locked"
      end
      lock = Lock.acquire(task.exec,'x')
      raise ActiveRecord::Rollback, "Resourse locked by another task" unless lock
      @task.locks << lock
      #  
      doc.xpath("//inputs//files").each do |entry|
        lock = Lock.acquire( @task.path+entry.content,'r')
        raise ActiveRecord::Rollback, "Resourse locked by another task" unless lock
        @task.locks << lock
      end
      doc.xpath("//output//files").each do |entry| 
        lock = Lock.acquire(@task.path+entry.content,'w')
        raise ActiveRecord::Rollback, "Resourse locked by another task" unless lock
        @task.locks << lock
      end
      f.close
      task.save!
     end
  end

  #check it there a proc is running
  # => Check if there is a running process with the given name(windows OS required)
  # => return true if running
  def check_proc_is_running(exec)
    res =  %x[tasklist /FI "imagename eq #{exec}" /nh] #'tasklist /FI "imagename eq ruby.exe" /nh'
    res.include?exec
  end

end
