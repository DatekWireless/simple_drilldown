# frozen_string_literal: true

class SampleDrilldownController < DrilldownController
  # What fields should be displayed as default when listing actual Post records.
  default_fields %w[created_at user title]

  # The main focus of the drilldown
  target_class Post

  # How should we count the reords?
  select 'count(*) as count'

  # When listing records, what relations should be included for optimization?
  list_includes :user, :comments

  # In what order should records be listed?
  list_order 'posts.created_at'

  # Field definitions when listing records
  field :created_at
  field :title

  # The "attr_method" option transforms the value from the database to a
  # readable form.
  field :user, attr_method: ->(post) { post.user.name }
  field :body, attr_method: ->(post) { post.body[0..32] }
  field :comments, attr_method: ->(post) { post.comments.count }

  dimension :calendar_date, 'DATE(posts.created_at)', interval: true
  dimension :comments, 'SELECT count(*) FROM comments c WHERE c.post_id = posts.id'
  dimension :user, 'users.name', includes: :user
  dimension :day_of_month, "date_part('day', posts.created_at)"
  dimension :day_of_week, "CASE WHEN date_part('dow', posts.created_at) = 0 THEN 7 ELSE date_part('dow', posts.created_at) END",
            label_method: ->(day_no) { Date::DAYNAMES[day_no.to_i % 7] }
  dimension :hour_of_day, "date_part('hour', posts.created_at"
  dimension :month, "date_part('month', posts.created_at",
            label_method: ->(month_no) { Date::MONTHNAMES[month_no.to_i] }
  dimension :week, "date_part('week', posts.created_at)"
  dimension :year, "date_part('year', posts.created_at)"
end
