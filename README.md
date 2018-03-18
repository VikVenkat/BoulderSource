Builder Scraping Tool

This is a small application to try to find and play with builder data. Most of the work and design has been in making this an easy and effective commandline app.

Available commands (from within console)

Scraping:

 - List.new.set_builder_info(start_page, no_pages, state)
 Will create a new list. All parameters optional. Works best in small batches, say 200 or 500.

  - Builder.dedupe
  Will dedupe builder records

  - Builder.fill_emails(limit, starting_record)
  Will look up emails for the builder records. Works best in batches. Parameters optional.

Can download full CSV by pointing your browser then at {localhost}/builders.csv
