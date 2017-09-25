require 'mixpanel-ruby/events'
require 'time'

module MixpanelRubyBatch

  module Events

    # Tracks a batch of events for a single distinct_id.
    # Events should be passed as an array, with each element either a
    # Hash or a string. Each Hash element should have a single key (the event name,
    # as a string) with the value a Hash of properties. Each string element
    # will be interpreted as an event name with no properties.
    #
    #     tracker = Mixpanel::Tracker.new
    #
    #     tracker.track_batch("12345", [
    #     "Signup Begin",
    #     {
    #       "Signup Complete" => {
    #         "User Sign-up Cohort" => "July 2013"
    #       }
    #     },
    #     {
    #       "Welcome Email Sent" => {
    #         "Email Template" => "Pretty Pink Welcome",
    #         "User Sign-up Cohort" => "July 2013"
    #       }
    #     }])
    def track_batch(distinct_id, events, ip=nil, endpoint=:event)
      data = events.map do |event_name_or_hash|
        event = event_name_or_hash
        properties = {}

        if event_name_or_hash.is_a?(Hash)
          event_data = event_name_or_hash.flatten
          event = event_data[0]
          properties = event_data[1]
        end

        properties = {
          "distinct_id" => distinct_id,
          "token" => @token,
          "time" => Time.now.to_i,
          "mp_lib" => "ruby",
          "$lib_version" => Mixpanel::VERSION
        }.merge(properties)

        properties["ip"] = ip if ip

        {
          "event" => event,
          "properties" => properties
        }
      end

      data.each_slice(50) do |slice|
        message = { "data" => slice }
        if endpoint == :import
          message["api_key"] = ENV['MIXPANEL_API_KEY']
        end

        @sink.call(endpoint, message.to_json)
      end
    end

    def import_batch(distinct_id, events, ip=nil)
      track_batch(distinct_id, events, ip=nil, :import)
    end

  end

end

Mixpanel::Events.send(:include, MixpanelRubyBatch::Events)
