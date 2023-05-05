import flixel.ui.FlxButton;

class FancyButton extends FlxButton{

    public function new(X:Float = 0, Y:Float = 0, ?Text:String="", ?OnClick:Void->Void)
    {
        super(X, Y, Text, OnClick);
    }

    override public function updateStatusAnimation(){
        var curAnim = animation.name;
        var newAnim = statusAnimations[status];
        //trace(curAnim +" -> "+newAnim);
        
        switch (newAnim){
            case 'normal':
                if(!animation.finished && curAnim == "highlight"){
                    animation.reverse();
                }
                else if(curAnim != 'normal'){ 
                    //Edge case fix lol, happens after holding down click, activating 'pressed'
                    animation.play("highlight", true, true); 
                    animation.finishCallback = (name:String) -> {
                        animation.play("normal", true);
                        animation.finishCallback=null;
                    }; 
                }
            case 'highlight':
                //Don't directly play "normal" or "pressed", just play "highlight" and reverse it
                animation.finishCallback=null;
                animation.play(newAnim, true);  
            case 'pressed':
                //This happens if you hold down click on the button
                
        }
    }
}