import flixel.ui.FlxButton;

class FancyButton extends FlxButton{

    public function new(X:Float = 0, Y:Float = 0, ?Text:String="", ?OnClick:Void->Void)
    {
        super(X, Y, Text, OnClick);
    }

    override public function updateStatusAnimation(){
        //trace(animation.name+" -> "+statusAnimations[status]);
        if(animation.name == "highlight" && statusAnimations[status]=="normal"){
            
            animation.finishCallback = (name:String) -> {
                animation.play("normal", true);
                animation.finishCallback=null;
            };

            animation.play("highlight",true, true);

        }
        
        if(statusAnimations[status]=="normal"){
            return; //Don't play "normal", let the other animation finish
        }
        else{
            animation.finishCallback=null;
            animation.play(statusAnimations[status], true);
        }
    }
}