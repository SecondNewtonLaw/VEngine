# V8Engine
A mostly-type-safe Roblox Game Development Framework.

## Main features:
- Type definitions
- ~~Stable~~ (Not yet)
- Flexible

## Requirements:
- Roblox LSP
- Selene
- Rojo

### How does it work?
The framework has two stages. 
- ReplicatedFirst
- Initialization

ReplicatedFirst is initialized on replicated first, as the name implies.

The Initialization stage is ran under `StarterPlayer/StarterPlayerScripts/EngineRuntime` (For clients) and `ServerScriptService/EngineRuntime` (For servers)

Basically, a basic loading system for the way the modules run.

As for how types work, using Roblox LSP, you can set `robloxLsp.workspace.library` to automatically import types into your editor by default, using this, we make it so Roblox LSP automatically includes the types for all our `Packages` from wally, all V8Engine definitions under `EngineTypeDefinitions`, and your own custom definitions under `CustomTypeDefinitions`. Which allows you to use type notation without any issues, another tool which allows us to do this, is Selene, by integrating our own type library for V8Engine types, although its cumbersome to write, you can also write your own custom types using it, allowing you to make custom global functions.

## Why does this exist?
The times I have done Roblox games using frameworks, I kept going back to the idea of "Frameworks ruin my workflow". After giving it some thought, I realized that on all my projects I had editor-level documentation and a good LSP which provided me with smart and quick type completion, which coincidentally frameworks completely ruin entirely, this is because Roblox LSP cannot really tell what your ModuleScript returns as it won't go and fetch the contents when using a custom require function. This framework aims to disappear that annoyance entirely, and make it so developing only using Studio and Visual Studio Code possible, without having to detour into documentation pages all the time for the smallest of functions.

## Remarks:
This is REALLY just an experiment! It is currently on an unreleasable, really unstable, I have hope on make this a useful and maybe promising new framework.
To have a good experience using this, I will have to make a LOT of glue for types for packages it includes, like Red, which progress is being made in already, as I'm just missing some details, and soon this may be usable.