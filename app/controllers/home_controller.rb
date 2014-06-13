class HomeController < ApplicationController
  
  def index
    #Dir.chdir Rails.root
    #@signGen = Task.build("signgen")
    #@extract = Task.build("packetfinder")
    #@checkObet = Task.build("checkObet") 
    #@genSynt = Task.build("gensynth")
    #@checkSeqCount = Task.build("checkSeqCount")
    #@paramfinder = Task.build("paramfinder")
    #@db_versions = Database.where(:active=>"t").order(:version)
    #@goods = Telemetry.list("telemetries/IXV")
  end
  
  def vital_layer
    render "_vital_layer"
  end

  def experiment
    render "_experiment"
  end

end
