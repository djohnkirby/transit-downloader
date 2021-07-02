# frozen_string_literal: true
require "down"
require "zip"

def lambda_handler(event:, context:)
  #get the fileopen
  tempfile = Down.download("http://data.trilliumtransit.com/gtfs/path-nj-us/path-nj-us.zip")
  destination = 'tmp'
  FileUtils.mkdir_p(destination)
  Zip::ZipFile.open(tempfile) do |zip_file|
    zip_file.each do |f|
      fpath = File.join(destination, f.name)
      zip_file.extract(f, fpath) unless File.exist?(fpath)
    end
  end
end

lambda_handler(event: nil, context: nil)
