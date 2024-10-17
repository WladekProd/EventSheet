# EventSheet Plugin - Godot 4

![Demo Image](https://github.com/user-attachments/assets/3372e752-4e49-4e87-90f2-61b9b195eaff)

The plugin is just a visual shell with a little functionality, but it cannot execute the code itself when the game starts. It has a basic implementation of code execution from the event table, but it is very simple. If there are experts in Godot 4 and want to improve this plugin you can clone this repository and create it.

The full implementation of this plugin will facilitate the transition of Construct 3 engine users to Godot 4 and open more opportunities in the realization of 2D games and in 3D. With the help of this plugin it will be easier and more convenient to create games without programming.

The project is completely free and open source under the very free [MIT license](https://github.com/WladekProd/EventSheet/blob/main/LICENSE).
## FAQ

#### What is an Event Sheet:

Events consist of conditions that check if certain criteria are met, e.g. “Is the spacebar pressed?”. If all conditions are met, all actionsin the event occur, e.g. “Create bullet object”.
After all actions, there are sub-events that can check for other conditions, create more actions, more sub-events, and so on. Using this system, we can create complex functionality for our games and applications.

#### The “addons” folder:

- event_sheet - this is the main EventSheet plugin.
- plugin_refresher - (for developers) plugin allows to restart the main EventSheet plugin without restarting the project.
- explore-editor-theme - (for developers) plugin allows you to get standard icons and colors of Godot 4 Editor.

#### Folder “demo_project”:

- Stores the demo scene and the object to be created to test the execution of the visual code.

#### Folder “event_sheet”:

- Stores the last save of the Editor's event sheet.
## Authors

- [@wladekprod](https://github.com/WladekProd)

