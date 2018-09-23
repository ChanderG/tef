import termbox;
import std.range;
import std.algorithm;
import std.conv;

void drawText(string[] text) {
	auto trunc = text.take(height-2).map!(a => a.take(width-2)).array.to!(string[]);
	foreach (j, line; trunc) foreach (i, t; line) setCell(1+cast(int)i, 1+cast(int)j, t, Color.white, Color.basic);
	flush;
}

void main()
{
	init;

	drawText(["Hi there", "Hello World."]);

	Event e;
	do {
		pollEvent(&e);
	} while (e.key != Key.esc);

	shutdown;
}
