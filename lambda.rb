# frozen_string_literal: true
require "down"
require "zip"
require "aws-sdk"

def files_downloaded?(destination:)
  tempfile = Down.download("http://data.trilliumtransit.com/gtfs/path-nj-us/path-nj-us.zip")


  FileUtils.mkdir_p(destination)
  Zip::ZipFile.open(tempfile) do |zip_file|
    zip_file.each do |f|
      fpath = File.join(destination, f.name)
      zip_file.extract(f, fpath) unless File.exist?(fpath)
    end
  end

  true

rescue StandardError => e
  puts "Error downloading and unzipping files: #{e.message}"
  false
end

def object_uploaded?(s3_resource, bucket_name, object_key, file_name)
  bucket = s3_resource.bucket(bucket_name)
  bucket.object(object_key).upload_file(file_name)
rescue Aws::S3::Errors::ServiceError => e
  puts "Error uploading object: #{e.message}"
  false
end

def objects_uploaded?(destination:)
  s3 = Aws::S3::Resource.new(
    region: "us-east-1",
    access_key_id: "",
    secret_access_key: ""
  )
  Dir[destination + '/*'].reduce(true) { |acc, filename| acc && object_uploaded?(s3, 'transitservice-test', filename[4..-1],filename)}
end

def lambda_handler(event:, context:)
  files_downloaded?(destination: 'tmp') && objects_uploaded?(destination: 'tmp')
end
