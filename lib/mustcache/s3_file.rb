require 'aws'

module Mustcache
  class S3File
    attr_reader :bucket, :bucket_name, :checksum, :relative_path, :base_path

    def initialize(bucket_name, checksum, relative_path, base_path)
      @bucket_name   = bucket_name
      @checksum      = checksum
      @relative_path = relative_path
      @base_path     = base_path
    end

    def url
      s3_object.exists? ? s3_object.public_url : nil
    end

    def upload(local_path)
      s3_object.write(local_path).kind_of?(AWS::S3::S3Object)
    end

    def available?
      s3_object.exists?
    end

    def path
      "#{File.join(base_path, relative_path, checksum)}.tar.gz"
    end

    def index
      "s3://#{File.join(bucket_name, path)}"
    end

    private

      def s3
        @s3 ||= AWS::S3.new
      end

      def s3_object
        bucket.objects[path]
      end

      def bucket
        @bucket ||= s3.buckets[bucket_name]
      end

  end
end
