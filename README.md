# Komagire

[![Gem Version](https://badge.fury.io/rb/komagire.svg)](http://badge.fury.io/rb/komagire)
[![Build Status](https://travis-ci.org/troter/komagire.svg?branch=master)](https://travis-ci.org/troter/komagire)
[![Coverage Status](https://coveralls.io/repos/troter/komagire/badge.svg)](https://coveralls.io/r/troter/komagire)
[![Code Climate](https://codeclimate.com/github/troter/komagire/badges/gpa.svg)](https://codeclimate.com/github/troter/komagire)

Compose an object from comma separated keys.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'komagire'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install komagire

## Usage

Compose an object from `|` separated keys.

```ruby
class Tag < ActiveRecord::Base
end

Tag.create(id: 1, name: 'ruby')
Tag.create(id: 2, name: 'perl')
Tag.create(id: 3, name: 'java')

class Post < ActiveRecord::Base
  composed_of_komagire_key_list :tags, :tag_names, 'Tag', :name, komagire: {delimiter: '|', sort: true}
end

post = Post.new
post.tags = 'ruby|java'
post.tags.class # => Komagire::KeyList
post.tags       # => [#<Tag:0x007f8fea2e46c8 id: 1, name: "ruby">,#<Tag:0x007f8fea2e44c0 id: 3, name: "java">]
post.save
post.tag_names  # => '|java|ruby|'
```

Compose an object from comma separated ids.

```ruby
class Post < ActiveRecord::Base
  composed_of_komagire_id_list :tags, :tag_ids, 'Tag', komagire: {sort: true}
end

post = Post.new
post.tags = '1,2'
post.tags.class # => Komagire::IdList
post.tags       # => [#<Tag:0x007f8fea2e46c8 id: 1, name: "ruby">,#<Tag:0x007f8fea2e44c0 id: 3, name: "java">]
post.save
post.tag_ids    # => ',1,2,'
```

Convertion option.

```ruby
# comma separated ids
post.tags = '1,2'                      # string
post.tags = %w[1 2]                    # array of string
post.tags = [1, 2]                     # array of integer(id)
post.tags = [Tag.find(1), Tag.find(2)] # array of Tag
post.tags = Tag.where(id: [1, 2])      # ActiveRecord::Relation
post.tags = Komagire::IdList.new('Tag', '1,2', sort: true) # same object
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/troter/komagire. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

