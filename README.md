# README

## Media Catalog

This is a combination experiment and implementation of my local media library along with my collection records (LPs), CDs, and mp3 files.

### Rails Goals

- Use Rails 8 as vanilla as possible (.erb, test instead of rspec, rails 8 auth)  ✅
- Use Docker container to manage all dependencies inside container ✅
- Use Tailwindcss for styling  ✅
- ~~Deploy using Kamal to external service~~

### Functional Goals (features)

- Show all Music Media from Vinyls, CDs, and mp3s 
    - ✅ Vinyl
    - CDs
    - mp3
- Possibly show DVDs and/or blu-rays (time permitting)
- User authentication to add media and add categories
    - ✅ 1st pass done 
- ✅ ~~Import iTunes data to seed initial database~~  
- ~~Album art on main page~~
- ✅ Play counter to let me know how many times I've played an album 
- Default view to show all media
- Search functionality 
- maybe SPA up the site and not load pages
    - look into using the turbo / hotwire stuff for that
- ✅ Create API for third party use
    - document using Rswag Gem


### API Access

Using a very basic `X-Auth-Api: <Token>` based authorization tied to the `User` account via `User.api_token` field

To regenerate a token, use the built-in from the user model:

`User.find(<id>).regnerate_api_token!`



### RDBMS Structure

Since this is a trivial single use instance (for personal use only), going to use sqlite as I expect no more than 1 user at a time ... ME :)

After trial and error with Relational structure, going to follow approach recommened by Claude's analyis of Discogs' structure since that is the source I will be querying / inserting against.

[Table Structure](vendor/readme-assets/01.png)

[Sample Tree](vendor/readme-assets/02.png)

[Sample Tree](vendor/readme-assets/03.png)


# Local Dev instructions

- `overmind s`
- Since we are setup in a `.devcontainer` environment on VSCode, everything should be setup and ready to go locally
- directive(s) are stored in the `.overmind.env` file

### Credentials Edit

`EDITOR="code --wait" rails credentials:edit`

### Temporarily mount host Volumes

If we need access to the Host machine volumes (aka my local machine), run the following command:

- `docker run --mount type=bind,source=/Volumes,target=/mnt/volumes -it discogs_media-rails-app`

This will allow the root level `/Volumes` to be accesseable from inside the container in `/mnt/volumes`

## Deployment instructions

### AdHoc implementation using existing VPS

```bash
docker compose -f docker-compose.vps.yml --env-file .env build --no-cache web

# docker compose up :
docker compose -f docker-compose.vps.yml --env-file .env up -d

# rebuild after rails updates
docker compose -f docker-compose.vps.yml --env-file .env up --build -d

# to copy local files to the vps:
docker cp ./storage/. discogs-media-web:/rails/storage/
docker exec -u root discogs-media-web chown -R 1000:1000 /rails/storage

# if needed (after copying dev -> prod db)
docker exec -it discogs-media-web bin/rails db:prepare 
```