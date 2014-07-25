require 'thor'
require 'digest'
require 'mustcache/error'
require 'mustcache/s3_file'
require 'mustcache/uploader'
require 'mustcache/downloader'

module Mustcache
  class CLI < Thor
    include Thor::Actions

    namespace :default

    class_option :access_key_id,      type: :string,  required: true,  default: ENV['AWS_ACCESS_KEY_ID']
    class_option :secret_access_key,  type: :string,  required: true,  default: ENV['AWS_SECRET_ACCESS_KEY']
    class_option :bucket,             type: :string,  required: true
    class_option :base_path,          type: :string
    class_option :cache,              type: :hash,    required: true

    desc 'apply', 'Apply your cache'
    def apply
      options.cache.each do |file_path, directory_path|
        s3_file = s3_file(file_path, directory_path)
        apply_cache(s3_file, file_path, directory_path)
      end
    end

    desc 'save', 'Backup your cache directories'
    def save
      options.cache.each do |file_path, directory_path|
        s3_file = s3_file(file_path, directory_path)
        save_cache(s3_file, file_path, directory_path)
      end
    end

    private

      def apply_cache(s3_file, file_path, directory_path)
        if s3_file.available?
          say "Downloading cache file for: #{file_path}:#{directory_path} at #{s3_file.index}", :green
          Downloader.download(self, s3_file.url, directory_path)
        else
          say "No cache file available for #{file_path}:#{directory_path} at #{s3_file.index}", :yellow
        end
      rescue Mustcache::Error => e
        say e.to_s, :red
      end

      def save_cache(s3_file, file_apth, directory_path)
        if s3_file.available?
          say "Cache file already available for: #{file_path}:#{directory_path} at #{s3_file.index}", :green
        else
          say "Uploading cache file for: #{file_path}:#{directory_path} to #{s3_file.index}", :green
          Uploader.upload(self, s3_file, directory_path)
        end
      rescue Mustcache::Error => e
        say e.to_s, :red
      end

      def s3_file(file_path, directory_path)
        file_path_checksum = checksum(file_path)
        S3File.new(options.bucket, file_path_checksum, directory_path, options.base_path)
      end

      def checksum(file_path)
        Digest::MD5.file(file_path).hexdigest
      end

  end
end
