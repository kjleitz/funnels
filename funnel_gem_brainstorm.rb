# V2

# this...
funnel_event
  event: :new_item,
  user_id: current_user.id,
  label: "user is creating an item!"

# basically makes this...
{
  event: :new_item,
  user_id: 321 # automatically current_user.id (unless specified)
  label: "user is creating an item!",
}

# in ItemController

after_action :update, -> { funnel_event :update_item }

def new
  funnel_event :new_item, "user went to /items/new to create a new item"
  # which is shorthand for...
  funnel_event \
    event: :new_item,
    user_id: current_user.id, # could use the request IP address instead
    label: 'user went to /items/new to create a new item'
  end

def create
  funnel_event :create_item
  # which is shorthand for...
  funnel_event \
    event: :create_item,
    user_id: current_user.id,
    label: 'create item'
end

def edit
  funnel_event :edit_item
  # which is shorthand for...
  funnel_event \
    event: :edit_item,
    user_id: current_user.id,
    label: 'edit item'
end

def update
  funnel_event :update_item # maybe add model_type and model_id
end

# funnel reporting class

class ItemFunnels < Funnels::BaseFunnels
  funnel 'User creates and then edits an item' do |funnel|
    funnel.name :create_and_edit
    funnel.description "A user creates an item (by any means) and updates it (by any means)"
    funnel.track_by :user # or model_id/model_type?
    funnel.starts_with :new_item
    funnel.includes :create_item, required: true
    funnel.includes :edit_item
    funnel.ends_with :update_item
  end
  
  funnel 'User creates and then edits an item' do |funnel|
    # funnel.name defaults to what you'd get if you took the arg to `funnel` and
    # downcased it, removed all non-word and non-space characters, replaced all
    # whitespace with underscores, and then symbol-ized the string. e.g.,
    # "User edits an item's name" => :user_edits_an_items_name
    # funnel.description defaults to the arg passed to `funnel`.
    funnel.track_by model: Item
    funnel.starts_with :new_item
    funnel.includes :create_item
    funnel.includes :edit_item
    funnel.ends_with :update_item
  end
end

# example info exposed by the funnels:

ItemFunnels.all #=> \

[
  {
    id:   1,
    name: 'User creates and then edits an item',
    steps: [
      {
        step_number: 1,
        required:    false,
        event_key:   :new_item,
        event_label: 'user went to /items/new to create a new item',
        event_count: 15,
        requests: [
          {
            count:    12,
            method:   :get,
            url:      'www.example.com/items/new',
            referrer: 'www.example.com/items'
          },
          {
            count:    3,
            method:   :get,
            url:      'www.example.com/user/:id/items/new',
            referrer: 'www.example.com/user/:id/items',
          }
        ]
      },
      {
        step_number: 2,
        required:    true,
        event_key:   :create_item,
        event_label: 'create item',
        event_count: 11,
        requests: [
          {
            count:    9,
            method:   :post
            url:      'www.example.com/items'
            referrer: 'www.example.com/items/new'
          },
          {
            count:    1,
            method:   :post,
            url:      'www.example.com/user/:id/items',
            referrer: 'www.example.com/user/:id/items/new'
          },
          {
            count:    1,
            method:   :post,
            url:      'www.example.com/api/items',
            referrer: nil
          }
        ]
      },
      {
        step_number: 3,
        required:    false,
        event_key:   :edit_item,
        event_label: 'edit item',
        event_count: 6,
        requests: [
          {
            count:    5,
            method:   :get,
            url:      'www.example.com/items/:id'
            referrer: 'www.example.com/items'
          },
          {
            count:    1,
            method:   :get,
            url:      'www.example.com/users/:id/items/:item_id'
            referrer: 'www.example.com/users/:id/items'
          }
        ]
      },
      {
        step_number: 4,
        required:    true,
        event_key:   :update_item,
        event_label: 'update item',
        event_count: 3,
        requests: [
          {
            count:    2,
            method:   :patch,
            url:      'www.example.com/items/:id',
            referrer: 'www.example.com/items/:id'
          },
          {
            count:    1,
            method:   :patch,
            url:      'www.example.com/api/items/:id',
            referrer: nil
          }
        ]
      }
    ]
  },
  {
    id: 2,
    # ...
  }
]

funnel = ItemFunnels.first # or...
funnel = ItemFunnels.find :create_and_edit

# by default should only count hits in from_step and to_step where the user ids
# exist in both (review this logic later)
funnel.percent_proceeded from_step: 2, to_step: :update_item # use either step_number or event_key
#=> (3 / 11) * 100 == 27.27%

# if the funnel has certain events marked as required: true it uses the minimal
# intersection of the user_id sets of the "required" events to determine the
# actual participants of the funnel.

# the funnel events only track the first trigger of the event by that user,
# except when the funnel has multiple events by the same key (in which case it
# tracks twice: first for the first time since hitting the last :required event,
# second for the first time since triggering the last :required event or the
# last event by the same event_key, whichever is most recent)

# the funnel events track based on the timestamps of each sequential event


# Basic code stuff

module SimpleFunnels

end

class SimpleFunnels::Funnel < ActiveRecord::Base
  attr_accessor :name, :description, :user_id, :model_type, :model_id

  def track_by()
  end

  def starts_with(event_key)
  end

  def includes(event_key)
  end

  def ends_with(event_key)
  end

end

class SimpleFunnels::Funneler
  def funnel(funnel_desc, **options)
    return unless block_given?


  end
end
