Callbacks details
=================


See the [API documentation][api] for a complete example and details on how to register to these callbacks.

The 'plateData' table
---------------------

Several of the following callbacks have a *plateData* argument. This argument
is a table containing the following fields:

- **.name**: The name of the nameplate's associated unit.
- **.reaction**: The reaction of the unit as returned by the [:GetPlateReaction() API](http://www.wowace.com/addons/libnameplateregistry-1-0/pages/api/#w-addon-get-plate-reaction-plate-frame)
- **.type**: The type of the nameplate as returned by the [:GetPlateType() API](http://www.wowace.com/addons/libnameplateregistry-1-0/pages/api/#w-addon-get-plate-type-plate-frame)
- **.GUID**: The GUID of the nameplate's associated unit **which may be nil if it's not been found and cached already.**

This *plateData* argument is a direct reference to the library internal
registry. It's safe to use when inside a callback's firing scope but in other
cases **you must use the related API** to get accurate and up to date information.

**Do not modify *plateData* content in any way**, it's meant to be read only.
Modifying it or adding fields is not allowed and may break the library current
and futur releases.

* * * * * * * *

Main callbacks
--------------

Most of your code related to nameplates will rely on the following callbacks.

### LNR_ON_NEW_PLATE

*Fires when a nameplate appears on screen*

**Args:**

- *callbackName*: The name of the callback
- *plateFrame*: The nameplate's root frame
- *plateData*: The up to date data associated to the nameplate (see the plateData table details above)

* * * * * * * *

### LNR_ON_RECYCLE_PLATE

*Fires when a nameplate disappears from the screen.*

As you may have noticed, this callback contains the word 'recycle'. It's
important to understand that a nameplate isn't tied to a single unit but is
reused to display other units.

**Args:**

- *callbackName*: The name of the callback
- *plateFrame*: The nameplate's root frame
- *plateData*: The up to date data associated to the nameplate (see the plateData table details above)

* * * * * * * *

### LNR_ON_GUID_FOUND

*Fires when a GUID is successfully linked to a nameplate*

**NOTE:** This callback will *not fire* if the GUID has been previously cached
(if plateData.GUID is non-nil when LNR_ON_NEW_PLATE fires).


LibNameplateRegistry has to resort to a few tricks to link GUID to nameplates.
For now it just uses two:

- Nameplate **mouseover highlighting**: nameplates highlight slightly when you mouseover them
- Nameplate **targeting alpha change**: targetting a nameplate dims all the other nameplates

The library detects these changes in the nameplates and is able to precisely
link nameplates to unit GUIDs.

When the unit is a player character, its GUID is cached, when the unit is an
NPC the GUID is forgotten as soon as LNR_ON_RECYCLE_PLATE fires since an NPC's
GUID is not constant.

**Args:**

- *callbackName*: The name of the callback
- *plateFrame*: The root frame of the nameplate whose GUID was found
- *GUID*: the GUID that was discovered
- *methodUsed*: either 'mouseover' or 'target'

* * * * * * * *

### LNR_ON_TARGET_PLATE_ON_SCREEN

*Fires whenever a targeted unit's nameplate becomes visible or when a currently
displayed nameplate is targeted*

This is the only reliable way to know if a nameplate belongs to the player's current target.

**Args:**

- *callbackName*: The name of the callback
- *plateFrame*: The root frame of the nameplate
- *plateData*: The up to date data associated to the nameplate (see the plateData table details above)

* * * * * * * *


Diagnostic callbacks
--------------------

These are not necessary to register to use the library but are very useful to
diagnose issues your users could face.
These callbacks allows you to react to incompatibility situations and inform
your users accurately on what's happening.

### LNR_ERROR_FATAL_INCOMPATIBILITY

*Fires when LibNameplateRegistry internal diagnostics detect something
terribly wrong*

When this callback fires, a Lua error is also raised and the library
self-destructs (through a precisely controlled implosion without causing any
collateral damages).

This usually happens when:

- The nameplate manifest has changed.
- Inconsistencies are detected while hooking nameplate's frames.

The first can be caused by an upgrade of World of Warcraft (Blizzard regularly
changes nameplates frames) or by another add-on which, instead of hiding
default Blizzard sub-frames and creating its own, is modifying and rearranging them.

The second is always caused by another add-on hooking the nameplates' frames
the wrong way (by using frame:SetScript() instead of frame:HookScript())

When not in combat LibNameplateRegistry checks its hooks consistency every 10 seconds.

**Args:**

- *callbackName*: The name of the callback
- *incompatibilityType*: A short text string describing the problem:
    
    - *"NAMEPLATE_MANIFEST"*: The nameplates' frame are no longer following the expected format.
    - *"HOOK: OnHide"* or *"HOOK: OnShow"*: LibNameplateRegistry missed several nameplate show and hide events.
    - *"HOOK: OnShow missed"* a nameplate is hidden but was never shown...

* * * * * * * *

### LNR_ERROR_GUID_ID_HAMPERED

*Fires when LibNameplateRegistry fails to detect nameplates' mouse-hovering
highlighting*

This happens when another add-on is unduly modifying the nameplates.
This error is not fatal but LibNameplateRegistry will fail to link nameplates
to GUID...

**Args:**

- *callbackName*: The name of the callback
- *message*: A pre-formatted message to display to your users

* * * * * * * *

### LNR_ERROR_SETPARENT_ALERT

*Fires when another add-on is caught red-handed reparenting a nameplate's
status bar (the health bar)*

**usually fires a few moments before LNR_ERROR_FATAL_INCOMPATIBILITY**

This callback reports the name of the add-on.

The idea here is to use this callback to display a nice little message to your
users explaining the problem so *they* can report it directly to whoever is
concerned.

A pre-formatted message is provided for your convenience.

This has proven to be very effective to get problematic add-ons' author's
attention.

**Args:**

- *callbackName*: The name of the callback
- *baddon*: The problematic add-on's name
- *message*: A pre-formatted message to display to your users

* * * * * * * *

### LNR_ERROR_SETSCRIPT_ALERT

*Fires when another add-on is caught red-handed using :SetScript() instead of
":HookScript()*

This callback reports the name of the add-on and the offending file and line
number in its source code.

Should be used in the same way than LNR_ERROR_SETPARENT_ALERT.


**Args:**

- *callbackName*: The name of the callback
- *baddon*: The problematic add-on's name
- *proof*: Two line of the stack containing the file name and line number.
- *message*: A pre-formatted message to display to your users

* * * * * * * *

### LNR_DEBUG

*Fires at every 'Debug()' call in LibNameplateRegistry*

Useful when developing, you should register this callback before LNR_ON_NEW_PLATE.


**Args:**

- *callbackName*: The name of the callback
- *level*: The level of debugging (1 to 4 where 1 is an error, 2 a warning, 3 and 4 informational)
- *libMinor*: The MINOR revision of LibNameplateRegistry
- *...*: unlimited list of debug arguments that can be past to print();


[api]: http://www.wowace.com/addons/libnameplateregistry-1-0/pages/api/
