Boilerplate for building static promo sites with Docpad.

Tools:
- Helper to create meta tags for social sharing
- [Likely](https://github.com/ilyabirman/Likely) — social buttons without jQuery
- [richtypo.js](https://github.com/sapegin/richtypo.js) for better typography
- Custom solution for supplying data to templates from JSON files
- [Stylus](http://stylus-lang.com/) — CSS-preprocessor
- Gulp — concatenates and minifies code for production


## Getting Started

1. [Install DocPad](https://github.com/bevry/docpad)

2. Clone the project. Then go to project folder and run:

	``` bash
    npm install
	docpad run
	```

3. Open [http://localhost:9778/](http://localhost:9778/)

4. Start hacking away by modifying the `src` directory


## Build for production

Just run:

    ``` bash
    npm run static
    ```
And then grab files in `out` directory.


## Deploy
There is no task for deploying—choose you own method.
If you deploy via FTP, then you may use [vinyl-ftp](https://github.com/morris/vinyl-ftp)


## Typography
## Meta tags for social sharing