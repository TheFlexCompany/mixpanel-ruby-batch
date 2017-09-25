require 'mixpanel-ruby/people'
require 'json'
require 'date'
require 'time'

module MixpanelRubyBatch
  module People

    VALID_OPERATIONS = [
      "$set", "$set_once", "$add", "$append", "$union", "$unset", "$delete"
    ]
    ADDITIVE_OPERATIONS = [
      "$set", "$set_once", "$append", "$union", "$track_charge"
    ]

    # Send a generic batch update to \Mixpanel people analytics.
    # The profile updates should be passed as an array of Hash objects.
    # Each has should have a single string key that is the distinct id
    # on which the perform the updates. The value should be a Hash with valid
    # operation names (e.g. "$set", "$unset") as keys and the appropriate data
    # for each operation as values. For details about the operations and their
    # expected data, see the documentation at # https://mixpanel.com/help/reference/http
    #
    #    tracker = Mixpanel::Tracker.new
    #
    #    tracker.people.batch([
    #      {
    #        "12345" => {
    #          "$set" => {
    #             "$firstname" => "David"
    #          },
    #          "$unset" => ["Levels Completed"]
    #        }
    #      },
    #      {
    #        "67890" => {
    #          "$set" => {
    #            "$firstname" => "Mick"
    #          },
    #          "$unset" => ["Levels Completed"]
    #        }
    #      }
    #    ])
    def batch(profile_updates, ip=nil, optional_params={})
      messages = []
      profile_updates.each do |profile_update|
        profile_update.each_pair do |distinct_id, updates|
          updates.select! { |key, value| VALID_OPERATIONS.include?(key) }
          updates.each_pair do |operation, data|
            data = fix_property_dates(data) if ADDITIVE_OPERATIONS.include?(operation)

            message = {
              "$distinct_id" => distinct_id,
              operation => data
            }.merge(optional_params)

            message["$ip"] = ip if ip

            messages << message
          end
        end
      end

      messages.each_slice(50) { |slice| batch_update(slice) }
    end

    private

    def batch_update(messages)
      data = messages.map do |message|
        {
          "$token" => @token,
          "$time" =>  ((Time.now.to_f) * 1000.0).to_i
        }.merge(message)
      end

      message = { "data" => data }

      @sink.call(:profile_update, message.to_json)
    end
  end
end

Mixpanel::People.send(:include, MixpanelRubyBatch::People)
