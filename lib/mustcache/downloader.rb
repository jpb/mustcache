require 'securerandom'
require 'tmpdir'
require 'mustcache/error'

module Mustcache
  class Downloader
    attr_reader :cli, :url, :destination

    def initialize(cli, url, destination)
      @cli         = cli
      @url         = url
      @destination = destination
    end

    def self.download(cli, url, destination)
      self.new(cli, url, destination).download
    end

    def download
      download_backup
      extract
      cleanup
    end

    private

      def download_backup
        cli.run "wget -nv -O #{temp_path} #{url}"
        raise Mustcache::Error.new("Unable to download #{url}") unless $?.success?
      end

      def extract
        cli.run "tar -xzf #{temp_path} -C #{destination}"
        raise Mustcache::Error.new("Unable to extract #{temp_path} to #{destination}") unless $?.success?
      end

      def cleanup
        cli.run "rm -r #{temp_path}"
      end

      def temp_path
        @temp_path ||= File.join('/tmp', SecureRandom.hex)
      end

  end
end
