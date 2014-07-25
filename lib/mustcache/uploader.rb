require 'securerandom'
require 'tmpdir'
require 'mustcache/error'

module Mustcache
  class Uploader
    attr_reader :cli, :s3_file, :source

    def initialize(cli, s3_file, source)
      @cli     = cli
      @s3_file = s3_file
      @source  = source
    end

    def self.upload(cli, s3_file, source)
      self.new(cli, s3_file, source).upload
    end

    def upload
      if File.exists?(source)
        compress
        upload_backup
        cleanup
      else
        cli.say "Unable to upload #{source} as it does not exist", :red
      end
    end

    private

      def upload_backup
        s3_file.upload(temp_path)
      end

      def compress
        cli.run "tar -czf #{temp_path} -C #{source} ."
        raise Mustcache::Error.new("Unable to compress #{source} to #{temp_path}") unless $?.success?
      end

      def cleanup
        cli.run "rm -r #{temp_path}"
      end

      def temp_path
        @temp_path ||= File.join('/tmp', SecureRandom.hex)
      end

  end
end
