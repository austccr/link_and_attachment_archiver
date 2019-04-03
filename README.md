This script finds links in HTML text and saves a backup copy of them.

## Adding your morph.io API key securely

You need your morph.io API key to run this, as it requests records from the morph.io API. 
Find your key at https://morph.io/documentation/api .

Your morph.io API key should be set to the environment variable `MORPH_API_KEY`.
Accessed as:

```
ENV['MORPH_API_KEY']
```

### For morph.io runs

On your morph.io scraper's settings page, add the environment variable.

See the [morph.io secret values documentation](https://morph.io/documentation/secret_values).

### On your local machine

We use `dotenv` to add environment variables from a `.env` file locally.

Create the `.env` file by copying `.env.example`:

```
cp .env.example .env
```

Then replace the example string with your API key in your new `.env` file.

This file is listed in `.gitignore` and so won't be checked into your git
repository. In other words, it will only stay on your local machine, secret from
the web.

Now, to run the script with your secret key, execute it with `dotenv`:

```
bundle exec dotenv ruby scraper.rb
```

## TODOs

* [x] point this at more sources, like the main lobbywatch archive for example
* [x] handle updates
  * [x] if we don't have it, archive it
  * [x] if we already have the file for this source_url, don't update
  * [x] if we have it are there are errors, try again
* [ ] investigate 302 records
* [ ] if we get a cert missing https error from archive.org, try the http
    version of the links.
* [ ] write a proper description in the readme
