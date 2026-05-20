varying highp vec2 texCoordVarying;
precision mediump float;

uniform sampler2D sampler;

void main()
{
	gl_FragColor = texture2D(sampler, texCoordVarying);
}
