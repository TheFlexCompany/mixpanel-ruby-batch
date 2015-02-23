# mixpanel-ruby-batch

**mixpanel-ruby-batch** adds a simple interface for performing batch operations
using the [mixpanel-ruby](https://github.com/mixpanel/mixpanel-ruby) gem.

[mixpanel-ruby](https://github.com/mixpanel/mixpanel-ruby) already provides a `BufferedConsumer` class to
facilitate batch operations:

```ruby
buffered_consumer = Mixpanel::BufferedConsumer.new
begin
    tracker = Mixpanel::Tracker.new(YOUR_TOKEN) do |type, message|
      buffered_consumer.send(type, message)
    end

    tracker.track("Signup Begin")
    tracker.track("Signup Complete",  {'User Sign-up Cohort' => 'July 2013'})
    tracker.track("Welcome Email Sent", {
      'Email Template' => 'Pretty Pink Welcome',
      'User Sign-up Cohort' => 'July 2013'
    })

ensure
    buffered_consumer.flush
end
```

**mixpanel-ruby-batch** adds a slightly higher-level API by adding the
`Mixpanel::Events#track_batch` and `Mixpanel::People#batch` methods.

## Installation

```ruby
gem install mixpanel-ruby-batch
```

## Usage

```ruby
# Tracks a batch of events for a single distinct_id.
# Events should be passed as an array, with each element either a
# Hash or a string. Each Hash element should have a single key (the event name,
# as a string) with the value a Hash of properties. Each string element
# will be interpreted as an event name with no properties.

tracker = Mixpanel::Tracker.new

tracker.track_batch("12345", [
"Signup Begin",
{
  "Signup Complete" => {
    "User Sign-up Cohort" => "July 2013"
  }
},
{
  "Welcome Email Sent" => {
    "Email Template" => "Pretty Pink Welcome",
    "User Sign-up Cohort" => "July 2013"
  }
}])


# Send a generic batch update to Mixpanel people analytics.
# The profile updates should be passed as an array of Hash objects.
# Each has should have a single string key that is the distinct id
# on which the perform the updates. The value should be a Hash with valid
# operation names (e.g. "$set", "$unset") as keys and the appropriate data
# for each operation as values. For details about the operations and their
# expected data, see the documentation at # https://mixpanel.com/help/reference/http

tracker = Mixpanel::Tracker.new

tracker.people.batch([
  {
    "12345" => {
      "$set" => {
         "$firstname" => "David"
      },
      "$unset" => ["Levels Completed"]
    }
  },
  {
    "67890" => {
      "$set" => {
        "$firstname" => "Mick"
      },
      "$unset" => ["Levels Completed"]
    }
  }
])
```

Both methods handle slicing the data into 50-message chunks, so it is safe to
pass as many messages to either message as memory will allow.

## Additional Information

For more information please visit:

* [Mixpanel Ruby API Integration page](https://mixpanel.com/help/reference/ruby#introduction)
* [mixpanel-ruby documentation](http://mixpanel.github.io/mixpanel-ruby/)
