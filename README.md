# URL Params

## Learning Goals

- Create a dynamic route
- Use route parameters in the controller via the params hash

## Review

You already know how to create a static request, which is where you create a
page that doesn't take any parameters and simply renders a view. For example:
`localhost:3000/cheeses`. For Rails to process this request, the `routes.rb` file
contains a route such as:

```ruby
get '/cheeses', to: "cheeses#index"
```

This is mapped to the `cheeses` controller and its `index` action, which renders
an array of cheeses as JSON.

## Dynamic Requests

Consider this scenario: We're building a frontend feature for displaying data
about one individual cheese. It'd be nice to be able to request data about _one
individual cheese_, instead of only being able to retrieve an array of all
cheeses. Ideally, we'd use the ID of the cheese as part of the URL to identify
which cheese we're gathering data about: `localhost:3000/cheeses/3`.

We could make separate routes for each cheese:

```rb
# config/routes.rb

get '/cheeses/1', to: "cheeses#first"
get '/cheeses/2', to: "cheeses#second"
get '/cheeses/3', to: "cheeses#third"
```

But that would quickly get ridiculous. You would have to modify your web server
every time someone creates a new cheese! Enter **dynamic routes**:

```rb
# config/routes.rb

get '/cheeses/:id', to: 'cheeses#show'
```

A breakdown of the dynamic route process flow is below:

1. The `routes.rb` file takes in the request and processes it like normal,
   except this time it also parses the `3` as a **URL parameter** and passes it to the
   `CheesesController`.

2. From that point, the controller action that you write will parse the `3`
   parameter and run a query on the `Cheese` model.

3. Once we have the correct Cheese instance, we can render a JSON response.

In review, what's the difference between static and dynamic routes?

- Static routes have a fixed path. For example, the `/cheeses` path will always
  show a list of all cheeses.

- Dynamic routes will render different data based on the parameters in the path.
  For example, when `3` is passed in as the parameter to the `/cheeses/:id`
  route, the app should render the data for the cheese with an ID of `3`. When
  `222` is passed in, the app should render the data for the cheese with an ID
  of `3`.

## Code Implementation

In order to setup a dynamic request feature, we've got some tests already in
place:

```ruby
# spec/requests/cheeses_spec.rb

RSpec.describe 'Cheeses', type: :request do
  describe 'GET /cheeses/:id' do
    let!(:cheese) { Cheese.create!(name: "Cheddar", price: 3, is_best_seller: true) }

    it 'returns the cheese with the matching id' do
      get "/cheeses/#{cheese.id}"

      expect(response.body).to include_json({
        id: a_kind_of(Integer),
        name: 'Cheddar',
        price: 3,
        is_best_seller: true
      })
    end
  end
end
```

Running `bundle exec rspec` gives us an expected error:
`ActionController::RoutingError: No route matches [GET] "/cheeses/1"`. To
correct this error, let's draw a route in `config/routes.rb` that maps to a show
action in the `CheesesController`:

```ruby
get '/cheeses/:id', to: 'cheeses#show'
```

Here you will notice something that's different from the static route. The
`/:id` tells the routing system that this route can receive a parameter and that
the parameter will be passed to the controller's `show` action. With this route
in place, let's run our tests again.

You should see a new failure this time: `ActionController::RoutingError: uninitialized constant CheesesController`.

Once we stub out a `CheesesController` class in
`app/controllers/cheeses_controller.rb`, running the tests again will give us
yet another new failure:
`AbstractController::ActionNotFound: The action 'show' could not be found for CheesesController`.
This means that we need to create a corresponding `show` action in the
`CheesesController`. Let's get this failure fixed with the code below:

```ruby
# app/controllers/cheeses_controller.rb

class CheesesController < ApplicationController
  def show
  end
end
```

Run the tests again. TODO: capture test error and add here

If you start the Rails server and navigate to `/cheeses/1` or any other cheese
record, the router will know what you're talking about. However, the controller
still needs to be told what to do with the `id`.

### The Params Hash

We first need to get the ID sent by the user through the dynamic URL. This
variable is passed into the controller in a hash called `params`. Since we named
the route `/cheeses/:id`, the ID will be the value of the `:id` key, stored in
`params[:id]`. Let's set that up here:

```ruby
# app/controllers/posts_controller.rb

def show
  cheese = Cheese.find(params[:id])
  render json: cheese
end
```

In this line, our show action is running a database query on the `Cheese` model
that will return a cheese with an ID that matches the route parameters. It will
store this record in the `cheese` variable, which we can then use to render JSON
data for that cheese object.

And with that, all our tests are passing, and you now know how to create dynamic
routes in Rails!

The `params` hash will keep coming back throughout this phase, so make sure you
feel comfortable with this concept. For instance: if we wanted a different key
rather than `:id` in the params hash, what do you think would need to change?
Experiment a bit with the code in the `routes.rb` file and the controller, and
use `byebug` to test your assumptions!

## Summary

Dynamic routes are helpful when we want to associate some data from the URL with
a record from the database. To create a dynamic route, use the `:param_name`
syntax as part of the route, such as `get "/cheeses/:id", to: "cheeses#show"`.

The dynamic parts of the route will be available in the **params hash** in your
controller, so when a request comes in for `/cheeses/3`, you can access the
number `3` in your controller using `params[:id]`, and then look up the
associated record in the database.

## Resources

- [Rails Routing](https://guides.rubyonrails.org/routing.html)
