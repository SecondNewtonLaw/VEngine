# `VEngine`

`VEngine` is a framework built around easy-to-use modules. It does this by providing some pre-implemented modules, and their types.

#### Requirements:
    - Luau-Lsp (Language Server w/Studio Plugin)
    - Rojo
    - Selene
    - Aftman
    - Wally

## Design of `VEngine`
    
    - Client
    - Shared
    - Server

`Shared` and `Client` are placed on `ReplicatedFirst`, `Server` lives on `ServerStorage`.

`Shared` is meant to be code used to communicate within the `Client` and `Server` boundary. Do NOT include server logic that is important to the application here. `Shared` scripts are replicated to the client, and exploiters can read the bytecode, and get reverse engineer it to do ill on your game! `Shared` Modules should limit themselves to being basic code or abstractions on top of already existing things.

Good things to use `Shared` for:
    
    - Abstracting existing systems into easier interfaces.
    - Communicating using Red (Already included in VEngine)

Bad things to use `Shared` for:
    
    - Entire DataStore code (This should be splitted into an Abstraction (To get data) and an Implementation on the server)
    - Entire Server-Exclusive systems, with little communication to the client.

As `Shared` modules can be included in both `Server` and `Client` you must also take into account some functions should not be able to be run inside in one of both contexts. 

`VEngine` will manipulate the environment of all functions present on all the `Client`, `Server` and `Shared` modules to 'hook' functions inside of them, mainly with the purposes of aiding in debugging and tracing scripts, `VEngine` will automatically format exceptions if they are not handled gracefully, and provide some key information, like the Script in which it originated, if the Script was running inside of an `Actor` instance, or if it was parented to nil, although the latter is rare.

In `VEngine` inheritance does not use metatables.

## Runners

`VEngine` has three runners, which all by default execute inside of `Actor` instances to allow [`Parallel Luau`](https://create.roblox.com/docs/scripting/multithreading) to be used, the runners have also been enabled for [`Native Code Generation`](https://create.roblox.com/docs/luau/native-code-gen).

    - ReplicatedFirst Runner
    - Client Runner
    - Server Runner

The `ReplicatedFirst` runner will run only on the `Client`, and is executed before everything begins in it. The `Client` runner will NOT execute until all `ReplicatedFirst` `VEngine` code is run. Take this into account when designing your scripts!

All loaded `VEngine` modules that match the structure of a `BaseEngineModule` are loaded into the `EngineEnvironmentManager`, and can be obtained using it, this guarantees they are initialized, as opposed to requiring them, which does not guarantee them to be Initialized.


## Designing Games with `VEngine`
For designing games with `VEngine`, the recommended approach is to avoid coupling, whilist `VEngine` supports depending on modules, it is discouraged. Modules should depend on themselves, and if they have a dependency, it should only be on `VEngine` code or in `Shared` code, which allows for communication between `Server` and `Client`, but if it cannot be helped, and you must communicate, you may add extra functions into your Module, make a [`Luau Type`](https://luau-lang.org/typecheck) for it and depend on them using `VEngine`'s `EngineEnvironmentManager` function `EngineEnvironmentManager:GetEngineModule(moduleName: string)`.

It is recommended that you use features that are often underlooked, such as [`CollectionService`](https://create.roblox.com/docs/reference/engine/classes/CollectionService), which allows you to programatically get tagged instances, which can aid you in writing global scripts to handle behaviours for entire groups of instances. Say you have a kill brick, instead of making a script for each kill brick, you tag them with "KillBrick" and use this sample module to give them the behaviour of it.

```luau
--!strict
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local EngineTypes = require(ReplicatedFirst.EngineShared.EngineTypes)
local ModuleBaseConstructor = require(ReplicatedFirst.EngineShared.EngineModule)

local module = ModuleBaseConstructor.new()

module.ModuleName = "Server/Global/Killbricks"

function module:PreInitialize(_: EngineTypes.EngineEnvironmentManager)
	-- Empty
end

function module:Initialize(_: EngineTypes.EngineEnvironmentManager)
	print("Obtaining instances...")
	local bricks = CollectionService:GetTagged("KillBricks")

	for _, brick in bricks do
		if brick:IsA("BasePart") then
			brick.Touched:Connect(function(otherPart: BasePart)
				local parent = otherPart.Parent :: Instance
				if not parent:IsA("Model") then
					return
				end
				local player = Players:GetPlayerFromCharacter(parent)
				if not player then
					return
				end
				local playerCharacter = player.Character
				if not playerCharacter then
					return
				end
				local playerHumanoid = playerCharacter:FindFirstChildOfClass("Humanoid")
				if not playerHumanoid then
					return
				end
				playerHumanoid:TakeDamage(playerHumanoid.MaxHealth)
			end)
		else
			error("Incorrectly tagged KillBrick? " .. brick:GetFullName())
		end
	end
end

return module
```

---

### Have a suggestion?
Open an issue or a pull request and lets discuss it

## Quick notes:

#### Why are updates erratic and excessive?
I develop `VEngine` while developing my games, as such, on the go, I make edits to it, and improve it while trying to use it for its purpose, `VEngine` in its current state is how I have been developing my games, and from using it I have seen a productivity boost that raw scripts would not have given me, as such, I will continue developing it until I can say "_I don't know what more I could add_"

#### Why not metatables?
Metatables are magical. It is not that I don't understand them, is that they obscure some parts of the program.

#### A global is missing in my environment
This is normal, as the globals listed inside of the `EngineEnvironmentManager` are not the ones in Roblox completely, and Roblox by default "sandboxes" threads, meaning I cannot access the global table easily, resulting in making a manual mapping of everything, if this occurs to you, open an Issue, and I will look into it as soon as possible and solve it when I have time.

---

Thanks for using `VEngine`, have fun while at it.