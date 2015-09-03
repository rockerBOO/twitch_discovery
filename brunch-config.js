exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      // joinTo: 'js/app.js'
      // To use a separate vendor.js bundle, specify two files path
      // https://github.com/brunch/brunch/blob/stable/docs/config.md#files
      joinTo: {
       'js/app.js': /^(web\/static\/js)/,
       'js/vendor.js': /^(web\/static\/vendor\/js)/
      },

      // To change the order of concatenation of files, explictly mention here
      // https://github.com/brunch/brunch/tree/master/docs#concatenation
      order: {
        before: [
          'web/static/vendor/js/jquery.1.11.3.js',
          'web/static/vendor/js/autocomplete.js',
        ]
      }
    },
    stylesheets: {
      joinTo: {
       'css/app.css': "web/static/scss/app.scss",
       'css/vendor.css': /^(web\/static\/vendor\/css)/
      },
    },
    templates: {
      joinTo: 'js/app.js'
    }
  },

  modules: {
    autoRequire: {
      'js/app.js': ['web/static/js/app']
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to '/web/static/assets'. Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Which directories to watch
    watched: ["web/static", "test/static"],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/^(web\/static\/vendor\/js)/]
    },
    postcss: {
      processors: [
        require('autoprefixer')
      ]
    }
  }
};
