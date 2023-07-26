package helpers;

import haxe.ds.IntMap;

typedef NewCamSteps = {
    var camHUD: Float;
    var camGame: Float;
}



class RepeatingCameraSections 
{


    public function new( newCamSectionShit: IntMap<NewCamSteps> ): Void
        {

            super();

            this.newCamShit = newCamSectionShit;
        }
}
