# Route Params

## Learning Goals

- Create a dynamic route
- Use route parameters in the controller via the params hash

## Setup

Fork and clone this repo, then run:

```console
$ bundle install
$ rails db:migrate db:seed
```

This will download all the dependencies for our app and set up the database.

## Video Walkthrough

<iframe width="560" height="315" src="https://www.youtube.com/embed/BWeBbIDlHwI?rel=0&amp;showinfo=0" frameborder="0" allowfullscreen></iframe>

## Review

You already know how to create a static request, which is where you create a
page that doesn't take any parameters and simply renders a view. For example:
`localhost:3000/cheeses`. For Rails to process this request, the `routes.rb` file
contains a route such as:

```rb
get '/cheeses', to: 'cheeses#index'
```

This is mapped to the `cheeses` controller and its `index` action, which renders
an array of cheeses as JSON.

## Dynamic Routes

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

1. The `routes.rb` file takes in the request to `localhost:3000/cheeses/3` and
   processes it like normal, except this time it also parses the `3` as a **URL
   parameter** and passes it to the `CheesesController`.

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
  of `222`.

## Code Implementation

In order to setup a dynamic request feature, we've got some tests already in
place:

```rb
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

Running `learn test` gives us an expected error:
`ActionController::RoutingError: No route matches [GET] "/cheeses/1"`.

To correct this error, let's draw a route in `config/routes.rb` that maps to a
show action in the `CheesesController`:

```rb
get '/cheeses/:id', to: 'cheeses#show'
```

You will notice something that's different from the static route. The `/:id`
tells the routing system that this route can receive a parameter and that the
parameter will be passed to the controller's `show` action. With this route in
place, let's run our tests again.

You should see a new failure this time:
`AbstractController::ActionNotFound: The action 'show' could not be found for CheesesController`.

This means that we need to create a corresponding `show` action in the
`CheesesController`. Let's get this failure fixed by adding a show action to our controller:

```rb
# app/controllers/cheeses_controller.rb

class CheesesController < ApplicationController
  def index
    cheeses = Cheese.all
    render json: cheeses
  end

  def show
  end
end
```

Run the tests again. You'll see a new error:
`JSON::ParserError: unexpected token at ''`. We're getting this error because
we're not returning any JSON data from our controller action.

If you start the Rails server and navigate to `/cheeses/1` or any other cheese
record, the router will know what you're talking about so it won't return an
error. However, it won't display the requested content because the controller
still needs to be told what to do with the `id`.

### The Params Hash

We first need to get the ID sent by the user through the dynamic URL. This
variable is passed into the controller in a hash called `params`. Let's put a
`byebug` inside our `#show` action:

```rb
# app/controllers/posts_controller.rb

def show
  byebug
end
```

Run the tests to drop into the debugger and take a look at the value of
`params`. You should see this:

```rb
#<ActionController::Parameters {"controller"=>"cheeses", "action"=>"show", "id"=>"1"} permitted: false>
```

Since we named the route `/cheeses/:id`, the ID is the value of the `:id` key,
stored in `params[:id]`. You can verify that by checking the value of
`params[:id]` in `byebug`. So next we can set up our `#show` action to find and
display the requested cheese:

```rb
# app/controllers/posts_controller.rb

def show
  cheese = Cheese.find(params[:id])
  render json: cheese
end
```

In the first line, our show action is running a database query on the `Cheese`
model that will return a cheese with an ID that matches the route parameters. It
will store this record in the `cheese` variable, which we can then use to render
JSON data for that cheese object.

And with that, our test is passing, and you now know how to create dynamic
routes in Rails! You should also be able to run `rails s` and visit
`localhost:3000/cheeses/1` to see the JSON data for one individual cheese.

The `params` hash will keep coming back throughout this phase, so make sure you
feel comfortable with this concept. For instance: if we wanted a different key
rather than `:id` in the params hash, what do you think would need to change?
Experiment a bit with the code in the `routes.rb` file and the controller, and
use `byebug` to test your assumptions!

## Conclusion

Dynamic routes are helpful when we want to associate some data from the URL with
a record from the database. To create a dynamic route, use the `:param_name`
syntax as part of the route, such as `get "/cheeses/:id", to: "cheeses#show"`.

The dynamic parts of the route will be available in the **params hash** in your
controller, so when a request comes in for `/cheeses/3`, you can access the
number `3` in your controller using `params[:id]`, and then look up the
associated record in the database.

## Resources

- [Rails Routing](https://guides.rubyonrails.org/routing.html)
