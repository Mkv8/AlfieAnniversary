package;

#if FLX_DEBUG
import flixel.system.debug.console.ConsoleUtil;
import flixel.FlxG;
#end

class Debugger {
	/**
	 * Register a new function to use in any command.
	 *
	 * @param 	FunctionAlias		The name with which you want to access the function.
	 * @param 	Function			The function to register.
	 */
	public static inline function registerFunction(FunctionAlias:String, Function:Dynamic):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerFunction(FunctionAlias, Function);
		#end
	}

	/**
	 * Register a new object to use in any command.
	 *
	 * @param 	ObjectAlias		The name with which you want to access the object.
	 * @param 	AnyObject		The object to register.
	 */
	public static inline function registerObject(ObjectAlias:String, AnyObject:Dynamic):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerObject(ObjectAlias, AnyObject);
		#end
	}

	/**
	 * Register a new class to use in any command.
	 *
	 * @param	cl	The class to register.
	 */
	public static inline function registerClass(cl:Class<Dynamic>):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerClass(cl);
		#end
	}

	/**
	 * Register a new enum to use in any command.
	 *
	 * @param	e	The enum to register.
	 * @since 4.4.0
	 */
	public static inline function registerEnum(e:Enum<Dynamic>):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerEnum(e);
		#end
	}

	/**
	 * Unregisters a object
	 *
	 * @param 	ObjectAlias		The name of the object.
	 */
	public static inline function unregisterObject(ObjectAlias:String):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.registeredObjects.remove(ObjectAlias);
		ConsoleUtil.interp.variables.remove(ObjectAlias);
		#end
	}

	/**
	 * Unregisters a function
	 *
	 * @param 	functionAlias		The name of the function.
	 */
	public static inline function unregisterFunction(functionAlias:String):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.console.registeredFunctions.remove(functionAlias);
		ConsoleUtil.interp.variables.remove(functionAlias);
		FlxG.game.debugger.console.registeredHelp.remove(functionAlias);
		#end
	}
}