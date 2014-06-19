class TelemetriesController < ApplicationController
before_filter :signed_in_and_redirect
  def import
    @db=Database.find(params[:database_id])
    @files = params[:files]
    puts "[Telemetry_Controller]Uploading:\n"
    
    @files.each do |file|
      name = file.original_filename
      
      directory = "#{@db.path}"
      path = File.join(directory, name)
      puts "file:#{directory}\#{name}\n"
      File.open(path, "wb") { |f| f.write(file.read) }
    end
    flash[:notice] = "File uploaded"
    @db.importTelemetries
    respond_to do |format|
      format.html {redirect_to files_database_url(@db)}
      format.json { render json: @files }
    end
  end


  #POST databases/:database_id/telemetries/upload
  # => upload the telemetry file
  def upload
    @db=Database.find(params[:database_id])
    @files = params[:files]
    puts "[Telemetry_Controller]Uploading:\n"
    
    @files.each do |file|
      name = file.original_filename
      
      directory = "#{@db.path}/input"
      path = File.join(directory, name)
      puts "file:#{directory}\#{name}\n"
      File.open(path, "wb") { |f| f.write(file.read) }
    end
    flash[:notice] = "File uploaded"
    respond_to do |format|
      format.html {redirect_to files_database_url(@db)}
      format.json { render json: @files }
    end
  end

  def delete
    @db=Database.find(params[:database_id])
    if params[:uploaded] and params[:uploaded]=="true" then
      @directory = "#{@db.path}/input"
      @files = Dir.entries(@directory)
      @files.delete_at 0
      @files.delete_at 0
      puts @files
      #@files.delete_if {|f| f.directory?("#{@directory}/#{f}")}
      @files.each{|f| File.delete("#{@directory}/#{f}")}
    end
    if params[:processed] and params[:processed]!="false" then
      @directory ="#{@db.path}/processed/#{params[:processed]}"
      @files = Dir.entries(@directory)
      @files = @files.shift 2
      @files.each{|f| File.delete("#{@directory}/#{f}")}
      Dir.delete(@directory)
    end
    redirect_to root_url
  end

  #GET databases/:database_id/uploaded
  # => return the list of telemetries files uploaded for the selected database but not yet processed merged/splitted
  def uploaded
    db = Database.find(params[:database_id])
    @files = Dir.entries("#{db.path}/input")
    @files.delete_if{|f| !f.include?'.good'}
    @results = []
    @files.each do |entry|
      @results << {:name=>entry,:version=>db.version}
    end
    respond_to do |format|
      format.html
      format.json { render json: @results }
    end
  end

  #GET databases/:database_id/processed
  # => return the list of telemetries that are already been merged/splitted associated to the time they were processed
  def processed
    db = Database.find(params[:database_id])
    path = "#{db.path}/processed"
    @dirs = Dir.entries(path)
    @dirs.delete_if{|f| f.include?'.'}
    @results = []
    @dirs.each do |d| 
      files = Dir.entries("#{path}/#{d}").select { |name| name.include?'.good' }
      files.each do |entry|
        @results << {name:entry,time:Time.at(d.to_i)}
      end
    end
    respond_to do |format|
      format.html
      format.json { render json: @results }
    end
  end

  #GET telemetries/:id/logs.json
  # => return a json array of the logs file existing in the Logs subdirectory
  def logs
    @good = Telemetry.find(params[:id])
    @logs = Dir.entries(@good.path+"/Logs")
    @logs.delete_if{|f| !f.include? '.txt' and !f.include? '.csv'}
    @result = []
    @logs.each do |entry|
      @result << {:name=>entry,:id=>""}
    end
    respond_to do |format|
      format.html
      format.json { render json: @result }
    end
  end

  #GET telemetries/:id/synthetic.json
  # => return a json array of the synthetic .csv file existing in the Synthetic subdirectory
  def synthetic
    @good = Telemetry.find(params[:id])
    @result = []
    @synth = Dir.entries(@good.path+"/Synthetic")
    @synth.delete_if{|f| !f.include?'.csv'}
    @synth.each do |entry|
      @result << {:name=>entry,:id=>""}
    end
    respond_to do |format|
      format.html
      format.json { render json: @result }
    end
  end

  #GET  telemetries/:id/packets.json?:channel
  # => return the list of spid that are already been extracted from the telemetry
  def packets
    @good = Telemetry.find(params[:id])
    @packets = []
    if params[:channel] then
      @vc = @good.virtual_channels.find(params[:channel])
      @packets = @good.packets.where(:channel=>@vc.channel).order(:spid)
    else
      @packets = @good.packets.order(:spid)
    end
    respond_to do |format|
      format.html 
      format.json { render json: @packets }
    end
  end

  #GET  telemetries/:id/parameters.json?:packet
  # => return the list of parameters that are already been extracted from the telemetry
  # => if given the packets id return the only the parameters list of the associated packet's spid
  def parameters
    @good = Telemetry.find(params[:id])
    @parameters = []
    if params[:packet] and !params[:packet].blank? then
      spid= @good.packets.find(params[:packet]).spid
      puts spid
      @parameters = @good.parameters.where(:spid=>spid).order(:name)
    else
      @parameters = @good.parameters.order(:name)
    end
    respond_to do |format|
      format.html
      format.json { render json: @parameters }
    end
  end

  #GET  telemetries/:id/virtual_channels.json
  # => return the list of virtual_channels from which had been extracted some parameters
  def virtual_channels
    @good = Telemetry.find(params[:id]) 
    @channels = [] 
    @channels += @good.virtual_channels.order(:channel)
    respond_to do |format|
      format.html
      format.json { render json: @channels }
    end
  end

  # GET /telemetries
  # GET /telemetries.json
  def index
    if (params[:database_id]) and !(params[:database_id]).blank? then
      @telemetries = Database.find(params[:database_id]).telemetries
    else
      @telemetries = Telemetry.all
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @telemetries }
    end
  end

  # GET /telemetries/1
  # GET /telemetries/1.json
  def show
    @telemetry = Telemetry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @telemetry }
    end
  end

  # GET /telemetries/new
  # GET /telemetries/new.json
  def new
    @telemetry = Telemetry.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @telemetry }
    end
  end

  # GET /telemetries/1/edit
  def edit
    @telemetry = Telemetry.find(params[:id])
  end

  # POST /telemetries
  # POST /telemetries.json
  def create
    @telemetry = Telemetry.new(params[:telemetry])
    respond_to do |format|
      if @telemetry.save
        format.html { redirect_to @telemetry, notice: 'Telemetry was successfully created.' }
        format.json { render json: @telemetry, status: :created, location: @telemetry }
      else
        format.html { render action: "new" }
        format.json { render json: @telemetry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /telemetries/1
  # PUT /telemetries/1.json
  def update
    @telemetry = Telemetry.find(params[:id])
    respond_to do |format|
      if @telemetry.update_attributes(params[:telemetry])
        format.html { redirect_to @telemetry, notice: 'Telemetry was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @telemetry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /telemetries/1
  # DELETE /telemetries/1.json
  def destroy
    @telemetry = Telemetry.find(params[:id])
    #path = "telemetries/IXV/#{@telemetry.database.version}/#{@telemetry.name}_#{@telemetry.version}"
    delete = %x[rm -R #{@telemetry.path}]
    @telemetry.destroy
    respond_to do |format|
      format.html { redirect_to telemetries_url }
      format.json { head :no_content }
    end
  end
end
