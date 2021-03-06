package systems;

import edge.ISystem;
import components.MouseLook;
import components.Transform;
import glm.GLM;
using glm.Vec3;
using glm.Quat;

class MouseLookSystem implements ISystem {
    var directionAxis:Vec3 = new Vec3(0, 1, 0);
    var qDirection:Quat = new Quat().identity();

    var elevationAxis:Vec3 = new Vec3(1, 0, 0);
    var qElevation:Quat = new Quat().identity();

    @:access(State)
    public function before():Void {
        if(!Game.state.pointerLocked) {
            Game.lockPointer();
            Game.state.dt_fixed = 0;
        }
        else {
            Game.state.dt_fixed = 1/60;
        }
    }

    public function update(transform:Transform, mouseLook:MouseLook) {
        if(!Game.state.pointerLocked) return;

        // smooth the mouse movement so things aren't quite so janky
        mouseLook.smoothX = GLM.lerp(mouseLook.smoothX, Game.state.mouseDeltaX, 1.0 / Settings.mouseSmoothing);
        mouseLook.smoothY = GLM.lerp(mouseLook.smoothY, Game.state.mouseDeltaY, 1.0 / Settings.mouseSmoothing);

        mouseLook.direction -= mouseLook.smoothX * Settings.mouseSensitivity * Game.state.dt_fixed;
        mouseLook.elevation -= mouseLook.smoothY * Settings.mouseSensitivity * Game.state.dt_fixed;        

        while(mouseLook.direction > 2 * Math.PI)
            mouseLook.direction -= 2 * Math.PI;
        while(mouseLook.direction < 0)
            mouseLook.direction += 2 * Math.PI;

        // clamp looking up or down to straight down or straight up,
        // don't go past that. Things get weird there.
        if(mouseLook.elevation < -Math.PI / 2)
            mouseLook.elevation = -Math.PI / 2;
        if(mouseLook.elevation > Math.PI / 2)
            mouseLook.elevation = Math.PI / 2;

        Quat.axisAngle(directionAxis, mouseLook.direction, qDirection);
        Quat.axisAngle(elevationAxis, mouseLook.elevation, qElevation);

        // the order of this is important!
        transform.rot.identity();
        transform.rot.multiplyQuats(qDirection, transform.rot);
        transform.rot.multiplyQuats(qElevation, transform.rot);
    }
}
