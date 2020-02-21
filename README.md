```
 ____                             _    
|_  /___ _ _  ___ ___ __ _ _ _ __| |_  
 / // -_) ' \(_-</ -_) _` | '_/ _| ' \
/___\___|_||_/__/\___\__,_|_| \__|_||_|
```

## Setup

1. Install requirements
    - Ruby 2.6.5 (if you're using rvm, you can see available Ruby versions with `rvm list` - run `rvm install 2.6.5` if it's not present)
    - [yarn](https://yarnpkg.com/lang/en/docs/install/)
    - [npm](https://www.npmjs.com/get-npm)

      [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) will also probably streamline setup 😛

1. Check out a copy of the application locally to the directory of your choice.

1. From that directory, `bundle install` to install needed gems. You may be prompted to run `yarn install --check-files` the first time you're doing this. If that's the case, do that, and then run `bundle install`

1. `rake db:migrate` to run all current migrations against your local database

1. `rake db:seed` to populate your database with data based on the provided JSON files

1. `rails s`

1. You should now be able to access your local Zensearch instance via http://localhost:3000


## Basic Usage

The application root (http://localhost:3000/) provides a simple way to run basic text searches against `Organization`, `Ticket`, and `User` objects. Type in your text, choose a format, and you're off to the races. If you're creating URLs manually, you can use file extensions to specify format as well - http://localhost:3000/search.json?text=ent and http://localhost:3000/search?text=ae&format=json will return the same results.

**NB**: not all fields for a given object are searchable this way - the `SearchableConcern` concern sets the various types of search fields up. You can see which fields are defined as 'fulltext' by invoking the `fulltext_attributes` class method in the console on whatever model you're curious about. Models can also define any _other_ types of searchable fields they support.

## Advanced Usage

The application supports scoped search as well. You can visit http://localhost:3000/search?user[name]=ent to see only users whose name matches "ent".

The application _also_ supports mixing and matching scopes - so http://localhost:3000/search?user[user_alias]=ent&org[name]=ent will return users whose alias , as well as organizations whose name matches "ent".

The list of all searchable attributes for each model can be found by invoking the `searchable_fields` class method in the console on whatever model you're curious about.

---

### Other notes

* Search conditions are chained via `OR` rather than `AND`. This felt like the right direction (in my experience `AND` searches can return unexpectedly-restrictive results for users), but if that assumption is off-base, consider that an additional possible future enhancement. 🙂
* I chose to use SQLite rather than Postgres (which would normally be my default), simply because of uncertainty about what reviewers have easily available, and it felt prudent to optimize for ease of setup.
* Not using Pull Requests felt weird, even for a solo project, so I started doing that partway through. In case that's valuable context for reviewers, you're welcome to check those out, too.
* There are a number of `Ticket` records in the JSON files which have what appears to be invalid data. I was initially on the fence about how to handle things, but reluctantly ended up [removing some referential integrity constraints](https://github.com/chrispatterson/zensearch/pull/1/files#diff-1acd2e7e27a227829d5d14a91c863bb6L87) in order to be able to import all records.
* `SearchEntities` and `BuildSearchScope` are service objects. I started using these pretty extensively at my last job, and I really like them as a way to encapsulate application logic and make it easy to put under test. [Here's one writeup](https://medium.com/@scottdomes/service-objects-in-rails-75ca74214b77) in case that's not old news for any reviewers.

### A non-exhaustive list of possible future enhancements

* Add support for additional MIME types
* Enhance error handling - if this was to run in production mode, we'd want to hook it up to Airbrake or some other monitoring tool
* Set up / configure continuous integration tool
* Expose advanced search settings through the web UI
