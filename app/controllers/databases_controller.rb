class DatabasesController < ApplicationController
    

  def activate
    @db = Database.find(params[:id])
    @db = @db.activate
    respond_to do |format|
      format.html
      format.json { render json: @db }
    end
  end

  #GET databases/:id/files.json
  # => return a json array of the .dat files currently existing for the given database
  def files
    db = Database.find(params[:id])
    @files = Dir.entries(db.path)
    @files.delete_if{|f| !f.include?'.dat'}
    @results = []
    @files.each do |entry|
      @results << {:name=>entry,:version=>db.version}
    end
    respond_to do |format|
      format.html
      format.json { render json: @results }
    end
  end

  #POST databases/:id/upload
  # => upload the given file
  def upload
    @db=Database.find(params[:id])
    @files = params[:files]
    @files.each do |file|
      name = file.original_filename
      directory = @db.path
      path = File.join(directory, name)
      File.open(path, "wb") { |f| f.write(file.read) }
    end
    flash[:notice] = "File uploaded"
    respond_to do |format|
      format.html {redirect_to files_database_url(@db)}
      format.json { render json: @files }
    end
  end

  # GET /databases
  # GET /databases.json
  def index
    @databases = Database.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @databases }
    end
  end

  # GET /databases/1
  # GET /databases/1.json
  def show
    @database = Database.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @database }
    end
  end

  # GET /databases/new
  # GET /databases/new.json
  def new
    @database = Database.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @database }
    end
  end

  # POST /databases
  # POST /databases.json
  # => create also the database structure folder if it does not exist
  def create
    @database = Database.new(params[:database])
    path = @database.path
    @database.active=false
    Dir.mkdir "telemetries/#{@database.mission}" unless Dir.exists? "telemetries/#{@database.mission}"
    if !Dir.exists? path then
      Dir.mkdir path
      Dir.mkdir path+"/input"
    end
    respond_to do |format|
      if @database.save
        format.html { redirect_to @database, notice: 'Database was successfully created.' }
        format.json { render json: @database, status: :created, location: @database }
      else
        format.html { render action: "new" }
        format.json { render json: @database.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /databases/1
  # PUT /databases/1.json
  def update
    @database = Database.find(params[:id])
    respond_to do |format|
      if @database.update_attributes(params[:database])
        format.html { redirect_to @database, notice: 'Database was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @database.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /databases/1
  # DELETE /databases/1.json
  # => delete the database folder and it's content
  def destroy
    @database = Database.find(params[:id])
    path = @database.path
    delete = %x[rm -R #{path}]
    @database.destroy

    respond_to do |format|
      format.html { redirect_to databases_url }
      format.json { head :no_content }
    end
  end
end
