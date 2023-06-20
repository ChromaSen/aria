package;

import openfl.display.Shader;
import openfl.filters.ShaderFilter;

class Handler
{
	public static var abb:ShaderFilter=new ShaderFilter(new Chroma());

	public static function chr(off:Float):Void
	{
		abb.shader.data.rOffset.value=[off];
		abb.shader.data.gOffset.value=[0.0];
		abb.shader.data.bOffset.value=[off*-1];
	}
}
