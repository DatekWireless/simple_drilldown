# SimpleDrilldown [![Test](https://github.com/DatekWireless/simple_drilldown/actions/workflows/test.yml/badge.svg)](https://github.com/DatekWireless/simple_drilldown/actions/workflows/test.yml)

`simple_drilldown` offers a simple way to define axis to filter and group records
for analysis.  The result is a record count for the selected filter and
distribution and the option to list and export the actual records.

## Usage

### Rails

For a given schema:

```ruby
ActiveRecord::Schema.define(version: 20141204155251) do
  create_table "users" do |t|
    t.string "name",   limit: 16, null: false
  end

  create_table "posts" do |t|
    t.string   "title",      null: false
    t.text     "body",       null: false
    t.integer  "user_id",    null: false
    t.datetime "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments" do |t|
    t.integer  "post_id", null: false
    t.integer  "user_id",    null: false
    t.string   "title",   null: false
    t.text     "body",    null: false
    t.integer  "rating",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
```

We have three entities:

```ruby
class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments
end

class User < ActiveRecord::Base
  has_many :comments
  has_many :posts
end

class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
end
```

#### Controller

Create a new controller to focus on posts.  Each drilldown controller focuses on
one main entity.

    bin/rails g simple_drilldown:controller User

```ruby
class PostsDrilldownController < DrilldownController

  # What fields should be displayed as default when listing actual Post records.
  default_fields %w{created_at user title}

  # The main focus of the drilldown
  target_class Post

  # How should we count the reords?
  select "count(*) as count".freeze

  # When listing records, what relations should be included for optimization?
  list_includes :user, :comments

  # In what order should records be listed?
  list_order 'posts.created_at'

  # Field definitions when listing records
  field :created_at
  field :title

  # The "attr_method" option transforms the value from the database to a
  # readable form.
  field :user, attr_method: lambda { |post| post.user.name }
  field :body, attr_method: lambda { |post| post.body[0..32] }
  field :comments, attr_method: lambda { |post| post.comments.count }

  dimension :calendar_date, "DATE(posts.created_at)", interval: true
  dimension :comments, "SELECT count(*) FROM comments c WHERE c.post_id = posts.id"
  dimension :user, 'users.name', includes: :user
  dimension :day_of_month, "date_part('day', posts.created_at)"
  dimension :day_of_week, "CASE WHEN date_part('dow', posts.created_at) = 0 THEN 7 ELSE date_part('dow', posts.created_at) END",
            label_method: lambda { |day_no| Date::DAYNAMES[day_no.to_i % 7] }
  dimension :hour_of_day, "date_part('hour', posts.created_at"
  dimension :month, "date_part('month', posts.created_at",
            label_method: lambda { |month_no| Date::MONTHNAMES[month_no.to_i] }
  dimension :week, "date_part('week', posts.created_at)"
  dimension :year, "date_part('year', posts.created_at)"
end
```

The controller inherits the ```index``` action and other actions to display the
results.

### Views

This gem includes views for the drilldown visualization using Bootstrap.

You can override any views by creating them in your `app/views/simple_drilldown` directory.
If you would like a local copy of the views for overriding you can use the generator.

    bin/rails g simple_drilldown:views


## Excel export

# TODO: Write about Excel export.

```ruby
{excel_type: 'Number', excel_style: 'ThreeDecimalNumberFormat'}
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_drilldown'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install simple_drilldown
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Release

```bash
$ rake release
```
