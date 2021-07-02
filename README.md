# EventedRecord

EventedRecord allows for the migration from an ActiveRecord CRUD-style app to an Event-Sourced pattern.

## How it works
The basic idea is that your AR mutations will be hijacked, allowing you to redirect them to the event stream of your choosing. Currently, events are simply logged, e.g.:

```
  o = Order.create(waiter_name: "Bob", table_number: 12)
  {
    :model_name=>"Order",
    :uuid=>"df11e637-febf-44c5-863b-ed232e360f67",
    :method=>:save,
    :new_values=>{
      "waiter_name"=>"Bob",
      "table_number"=>12,
      "uuid"=>"df11e637-febf-44c5-863b-ed232e360f67"
    }
  }
  ...standard AR logs...
```

A handler (subscribed to your event stream) can then take care of state updates in the database for you.

Once you've confirmed that your handlers are mutating data as expected, AR mutations can be disabled entirely, making the data stream the source of truth in your application (but retaining the projections stored the database for ease of access), allowing AR models to act as read models.

## Installation
* add `gem "evented-record", github: "aaronsnyder/evented-record", branch: "master"` to your Gemfile
* run `bundle install`.

## Usage
Update the parent class on your AR models to `EventedRecord`.

```
  class Order < EventedRecord
    ...
  end
```

## Try it out
A test app can be found [here](https://github.com/aaronsnyder/evented-record-test-app)
