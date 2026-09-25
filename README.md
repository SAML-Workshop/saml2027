## SAML 2027 Official Website

This is the repository for the 6th International Workshop on Software Architecture and Machine Learning (SAML 2027), co-located with ICSA 2027 in Sydney, Australia.

The website uses Jekyll and the Minimal Mistakes theme.

To preview the site locally, run `bundle install` followed by `bundle exec jekyll serve`, then open `http://localhost:4000/saml2027/`.

After editing JavaScript sources, run `npm ci` and `npm run build:js`. Commit the generated `assets/js/main.min.js` alongside the source changes; GitHub Pages uses this compiled file.

Run `bundle exec jekyll build && bundle exec ruby scripts/check_site.rb` to check the generated pages for broken internal links, missing assets, invalid heading order, and incorrect search metadata.
