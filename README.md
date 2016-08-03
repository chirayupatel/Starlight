# Installation Steps:
  1. Clone the repo: $ git clone https://github.com/flybits/Starlight.git
  2. Get the latest frameworks from Flybits [img_devportal_1 ]
    * Navigate to https://developer.flybits.com/ 
    * Download & extract 'All Architectures [HealthKit]' for the version of Xcode you are running.
       _NOTE: All architectures includes slices for simulators_
  3. Add all the frameworks downloaded into Starlight project, Embedded Binaries settings
  4. If you did not select 'Copy items if needed' when performing previous step, you need to add the path where the frameworks are located.
    4.1 Go to Build Settings -> 'Framework Search Paths'
    4.2 Edit the Framework Search Path for the Starlight target
    4.3 Drag and drop the folder where frameworks are located
    
  That's all steps needed for successfully building and running the project.

  
# Running the demo
When you build and run, you can follow the guidelines given on the app to play the game. But we need to setup things on Flybits Experience Studio to see the full effect of the game.

Create the following rules in Experience Studio with exact same name.
```
    // Boosts rules
    Name: "Boost: 1"
    Rule: Fitness step count is less than 1000
    
    Name: "Boost: 2"
    Rule: Fitness step count is greater than 1000 AND less than 3000
    
    Name: "Boost: 3"
    Rule: Fitness step count is greater than 3000 AND less than 5000
    
    Name: "Boost: 4"
    Rule: Fitness step count is greater than 5000 AND less than 7000
    
    Name: "Boost: 5"
    Rule: Fitness step count is greater than 7000    
    
    
    // Weather rules
    Name: "Weather: Tundra"
    Rule: Current temperature is less than 3˚C
    
    Name: "Weather: Lush"
    Rule: Current temperature is greater than 20˚C AND less than 32˚C
    
    Name: "Weather: Desert"
    Rule: Current temperature is less than 32˚C
```
    
In this demo, Starlight app occasionally checks for status of each rule and updated the app with appropriate assets. When the rule "Weather: Desert" becomes true because temperature today is more than 32˚C, then that rule becomes activated. The Starlight app changes the background to desert scenario. Similarly, for different weather, the background is changed to reflect the actual current weather condition. 

The boost rules uses user's fitness data to modify the game play. The more steps user takes, the recharge rate increases accordingly to encourage the user to become more active. These are few examples to illustrate the capabilities of Flybits.
    
To activate the rule "Boost: 3", your health data should have step count in the range 3000 to 5000. The app will automatically report these values to Flybits. 

If you want the assets to change then one of the weather rule has to become active. We have mapped few different places on Earth where we think the actual temperature is defined by the rules.
For example, to activate "Weather: Lush" rule, then simulate your device/simulator location to -3.044662 , -59.9671039. Similarly, for all the weather conditions, these are the latitude and longitude to simulate:
```
LUSH   => -3.044662,  -59.9671039
DESERT => 26.6505873,  12.72949
TUNDRA => 82.5053139, -62.4171657
```

#About the game - Starlight#
Starlight is a 2D side-scroller game that will take a player across many different worlds and pose exciting challenges along the way. Avoid obstacles, enemies and unlock custom ships based on your context and the in-game premium currency.

Built using Apple’s SpriteKit, Starlight is a game that utilizes parallax layering, particle effects, and sprite-based animations in a 2D side-scroller. The parallax system uses configuration objects to control elements such as speed, offsets, anchor points, color tinting and additional effects including borders and oscillation. The animation system currently supports texture name categories (i.e. "boost" which uses "boost_1.png" - "boost_n.png") and can play a specified subset of frames (i.e. 3 – 7, 9 – 4). SKTextureAtlases are employed to help keep the game running at a quick 60 FPS. Each of the games environments has been split into a series of texture atlases, each with their own theme. Using parallax groups, the game can switch between environments easily. Each roup uses a naming scheme such as foreground, background and skybox that has matching elements across themed atlases. For example, one minute a player could be in the barren tundra only to find themselves in the tropics a moment later. Enemy generators add further challenges to the game, whether it is a lazily coasting bomb or a charging chomper, defeating them requires skills!

###How can Flybits Help?###

Starlight was built from the ground up with a typical game structure: scenes, sprites and textures. It wasn’t built to ease the integration of context; it was built to illustrate how a game without context could have such a system integrated easily, after the fact. Once we had the core game concept, we discussed what context variables we wanted to support in the game such as location, weather, time of day, and fitness information such as step counters. These pieces of context could greatly enhance our game, but if built on their own, it would likely take several specialty systems to perform correctly. Fortunately, the Flybits Context Engine allows us to integrate many different pieces of context without having to do anything other than hook into the correct APIs.

The context rules are typically built as mathematical expressions that read almost as English sentences, i.e. temperature < 3° C, steps > 10000. Each of these rules can have a profound impact on gameplay – and the implementation is up to you! Some examples of rules that have been built into Starlight include:

The player’s boost will regenerate and decay at different speeds based on the number of steps taken in a given day, higher numbers yield slower boost decay and faster boost regeneration.
The weather in the player’s location will change the assets and particle effects in-game, i.e. it will snow and the player will be taken to the Tundra texture set when the temperature is less than 3° C.
When the player visits the Flybits offices, a special ship will be unlocked for use.

###Adding Context###

Incorporating context requires little effort on the part of the developer once the SDK has been integrated correctly (see above). The context rule engine is another aspect of the SDK and currently requires users to be logged in to Flybits’ servers. Once a user has been logged in, a call to the rules APIs is the only thing required.

There are currently two options for retrieving rule data:

`GetRules` – an API to retrieve all rules for the currently specified user token
`GetRule(ruleID)` – an API to retrieve a specific rule belonging to the currently specified user token and where ruleID is the rule’s SHA hash id. Rules are specified on the server side and context can be sensed from the client or the server depending on the data required.

A sample of how to retrieve rules from Flybits Context Manager:


```
// Retrieve all rules and compare them to the previous version we have stored (if any)
RuleRequest.GetRules { (rules, error) in
  if let rules = rules {
    for rule in rules {
      if !isSubscribedToContext(contextIndexForRuleName(rule.name)) {
        continue
      }

      let filteredRules = contextManager.rules.filter { $0.id == rule.id }
      if filteredRules.count > 0 {
        if filteredRules.first!.lastResult != rule.lastResult {
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Rules.RuleChanged, object: contextManager, userInfo: [Constants.Rules.Rule : rule])
        }
        filteredRules.first!.lastEvaluated = rule.lastEvaluated
        filteredRules.first!.lastResult = rule.lastResult
      } else {
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Rules.RuleAdded, object: contextManager, userInfo: [Constants.Rules.Rule : rule])
        contextManager.rules.append(rule)
      }
    }
  }
}.execute()
```

To take full advantage of the dynamic nature of the context engine, a Context Manager was built for Starlight, which will likely be pulled into the SDK for general use. The Context Manager uses the NSNotificationCenter in a typical publish and subscribe architecture to post notifications for any objects listening for context updates. As a result, the game’s main scene will receive these context updates and fire changes accordingly. One such example is when the rule relating the user’s location to the current weather conditions returns successfully (i.e. Weather – Tundra, temperature < 3° C), the atlas associated to the rule is loaded and passed in to the parallax system.

Two examples of updating game assets and rules based on context change:

```
func toggleContextChange(rule: FlybitsSDK.Rule) {
    if rule.lastResult != nil && !rule.lastResult! {
        return // Ignore rules that are false
    }

    if let ruleName = rule.name { // Rule names are used as keys
        if ruleName.hasPrefix(Constants.Rules.Boost) {
            playerNode.updateBoost(ruleName)
        } else if ruleName.hasPrefix(Constants.Rules.Weather) {
            let newAtlasName = ruleName.componentsSeparatedByString(" ").last!
            parallaxNode.switchAtlas(newAtlasName)
            if newAtlasName == "Tundra" {
                toggleRain(false)
                toggleSnow(true)
            } else if newAtlasName == "Lush" {
                toggleSnow(false)
                toggleRain(true)
            } else {
                toggleRain(false)
                toggleSnow(false)
            }
        }
    }
}
```

