require 'spec_helper'
require 'mixpanel-ruby-batch/people'

describe Mixpanel::People do
  before(:each) do
    @time_now = Time.parse('Jun 6 1972, 16:23:04')
    allow(Time).to receive(:now).and_return(@time_now)

    @log = []
    @people = Mixpanel::People.new('TEST TOKEN') do |type, message|
      @log << [type, JSON.load(message)]
    end
  end

  it 'should send a well formed batch engage/set message' do
    @people.batch([{
      "TEST ID" => {
        '$set' => {
          '$firstname' => 'David',
          '$lastname' => 'Bowie',
        },
        '$unset' => ['Levels Completed']
      }
    }])
    expect(@log).to eq([
      [:profile_update, 'data' => [
        {
          '$token' => 'TEST TOKEN',
          '$time' => @time_now.to_i * 1000,
          '$distinct_id' => 'TEST ID',
          '$set' => {
            '$firstname' => 'David',
            '$lastname' => 'Bowie'
          }
        },
        {
          '$token' => 'TEST TOKEN',
          '$time' => @time_now.to_i * 1000,
          '$distinct_id' => 'TEST ID',
          '$unset' => ['Levels Completed']
        },
      ]
    ]])
  end

  it 'should send batch engage/ message in batches of 50' do
    profile_updates = 75.times.map do |i|
      { "TEST ID" => { '$set' => { "prop_#{i}" => 'David' } } }
    end

    batches = 75.times.map do |i|
      {
        '$token' => 'TEST TOKEN',
        '$distinct_id' => 'TEST ID',
        '$time' => @time_now.to_i * 1000,
        '$set' => { "prop_#{i}" => 'David' }
      }
    end

    @people.batch(profile_updates)
    expect(@log).to eq([
      [:profile_update, 'data' => batches[0, 50]],
      [:profile_update, 'data' => batches[50, 25]]
    ])
  end

  it 'should reject invalid operations' do
    @people.batch([{
      'TEST ID' => {
        '$set' => {
          '$firstname' => 'David',
          '$lastname' => 'Bowie',
        },
        '$foo' => {
          '$bar' => 'baz',
        }
      }
    }])
    expect(@log).to eq([[:profile_update, 'data' => [{
      '$token' => 'TEST TOKEN',
      '$distinct_id' => 'TEST ID',
      '$time' => @time_now.to_i * 1000,
      '$set' => {
        '$firstname' => 'David',
        '$lastname' => 'Bowie'
      }
    }]]])
  end

end
