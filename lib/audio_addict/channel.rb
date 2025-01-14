module AudioAddict
  class Channel
    include Cache
    include AutoProperties
    include Inspectable

    attr_reader :radio

    def initialize(radio, properties)
      @radio = radio
      @properties = properties
    end

    def inspectable
      %i[key name id]
    end

    def active?
      # Seems like each network has a different way of marking inactive channels.
      # This is where we normalize it
      return false unless properties['asset_id']
      return false if (name[0] == 'X') && (key[0] != 'x')

      true
    end

    def track_history
      @track_history ||= track_history!
    end

    def track_history!
      response = radio.api.get "track_history/channel/#{id}"
      response.map { |track| Track.new self, track }
    end

    def current_track
      track_history.first
    end

    def similar_channels
      similar = properties['similar_channels']
      return [] unless similar

      ids = similar.map { |s| s['similar_channel_id'] }
      radio.search_by_id ids
    end

    def vote(direction = :up, track: nil)
      track ||= current_track
      endpoint = "tracks/#{track.id}/vote/#{id}"

      if direction == :delete
        radio.api.delete endpoint
      else
        radio.api.post "#{endpoint}/#{direction}"
      end

      log_like track if (direction == :up) && Config.like_log
    end

    def images
      properties['images']
    end

    def listen_urls
      @listen_urls ||= listen_urls!
    end

    def listen_urls!
      cache.get "#{radio.network}/listen_urls/#{key}"  do
        radio.api.get "listen/premium/#{key}"
      end
    end

  private

    def log_like(track = nil)
      track ||= current_track
      message = "#{radio.name} :: #{name} :: #{track.artist} :: #{track.title}"
      file = Config.like_log
      File.append file, message unless File.contains? file, message
    end
  end
end
