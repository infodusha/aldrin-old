require('esbuild').build({
    entryPoints: ['web.js'],
    bundle: true,
    minify: true,
    outfile: 'out.js',
    platform: 'browser',
    sourcemap: false,
    target: ['chrome90'],
}).catch((err) => {
    console.error(err);
    process.exit(1);
});
