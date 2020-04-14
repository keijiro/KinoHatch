KinoHatch
=========

![before](https://i.imgur.com/iMMXPbS.png)
![after](https://i.imgur.com/88hzYj1.png)

**KinoHatch** is a post processing effect that converts an image into
monochrome with hatching.

System requirements
-------------------

- Unity 2019.3
- HDRP 7.3

How To Install
--------------

This package uses the [scoped registry] feature to resolve package
dependencies. Please add the following sections to the manifest file
(Packages/manifest.json).

[scoped registry]: https://docs.unity3d.com/Manual/upm-scoped.html

To the `scopedRegistries` section:

```
{
  "name": "Keijiro",
  "url": "https://registry.npmjs.com",
  "scopes": [ "jp.keijiro" ]
}
```

To the `dependencies` section:

```
"jp.keijiro.kino.post-processing.hatch": "1.0.0"
```

After changes, the manifest file should look like below:

```
{
  "scopedRegistries": [
    {
      "name": "Keijiro",
      "url": "https://registry.npmjs.com",
      "scopes": [ "jp.keijiro" ]
    }
  ],
  "dependencies": {
    "jp.keijiro.kino.post-processing.hatch": "1.0.0",
    ...
```
