# Stretchy
[![Build Status](https://travis-ci.org/hired/stretchy.svg?branch=master)](https://travis-ci.org/hired/stretchy)

Stretchy is a query builder for [Elasticsearch](https://www.elastic.co/products/elasticsearch). It helps you quickly construct the JSON to send to Elastic, which can get [rather complicated](http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html). 

Stretchy is modeled after ActiveRecord's interface and architecture - query objects are immutable and chainable, which makes quickly building the right query and caching the results easy.

Stretchy is *not*:

1. an integration with ActiveModel to help you index your data
2. a way to manage Elasticsearch configuration
3. a general-purpose Elasticsearch API client

The first two are very application-specific. For any non-trivial app, the level of customization necessary will have you writing almost everything yourself. The last one is better handled by the [elasticsearch gem](http://www.rubydoc.info/gems/elasticsearch-api/).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stretchy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stretchy

## Usage

Stretchy is still in early development, so it does not yet support the full feature set of the [Elasticsearch API](http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html). It does support fairly basic queries in an ActiveRecord-ish style.

### Base

```ruby
query = Stretchy::Query.new(index: 'app_production', type: 'model_name')
```

From here, you can chain the following query methods:

### Match

```ruby
query = query.match('welcome to my web site')
query = query.match('welcome to my web site', field: 'title', operator: 'or')
```

Performs a full-text search for the given string. `field` and `operator` are optional, and default to `_all` and `and` respectively.

#### Variants

* `not_match` - filters for documents not matching a full-text search


### Where

```ruby
query = query.where(
  name: 'Exact Name',
  email: [
    'exact@email.com',
    'another.user.with.same.name@email.com'
  ]
)
```

Allows passing a hash of matchable options in `field: [values]` format. If any one of the values matches, that field will be considered matched. All fields must match for a document to be returned. See the [Terms filter](http://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-terms-filter.html) for more details.

If you pass `field: nil`, Stretchy will construct the relevant `not { exists: field }` filter and apply it as expected.

#### Gotcha

Matches _must_ be exact; the values you pass in here are not analyzed by Elasticsearch, while the values stored in the index are (unless you turned analysis off for that field).

#### Variants

* `not_where` - filters for documents *not* matching the criteria
* `boost_where` - boosts the relevance score for matching documents
* `boost_not_where` - boosts the relevance score for documents not matching the criteria

### Range

```ruby
query = query.range(field: 'rating', min: 3, max: 5)
```

Only documents with the specified field, and within the specified range (inclusive) match. You can also pass in dates and times as ranges. Currently, you must pass both a min and a max value.

#### Variants

* `not_range` - filters for only documents where the field is *outside* the given range
* `boost_range` - boosts the relevance score for matching documents

### Geo

```ruby
query = query.geo(field: 'coords', distance: '20mi', lat: 35.0117, lng: 135.7683)
```

Filters for documents where the specified `geo_point` field is within the given range.

#### Gotcha

The field must be mapped as a `geo_point` field. See [Elasticsearch types](http://www.elastic.co/guide/en/elasticsearch/reference/current/mapping-geo-point-type.html) for more info.

#### Variants

* `not_geo` - filters for documents outside the specified range
* `boost_geo` - boosts the relevance score for documents based on how far from the given point they are

### Boost Random

```ruby
query = query.boost_random(user.id, 1.4)
```

Provides a random-but-deterministic boost to relevance scores. The first parameter is required, and represents the random seed. The second parameter is optional, and represents the weight for the random factor. See [Random Scoring](http://www.elastic.co/guide/en/elasticsearch/guide/master/random-scoring.html) for more details.

### Results

```ruby
query.results
```

Executes the query and provides the parsed json for each hit returned by Elasticsearch. 

### Ids

```ruby
query.ids
```

Provides only the ids for each hit. If your document ids are numeric (as is the case for most ActiveRecord-integrated documents), they will be converted to integers.

This is somewhat intelligent - if you have already called `results` the ids will be fetched from there.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/stretchy/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
