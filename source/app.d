import termbox;
import std.range;
import std.algorithm;
import std.conv;

import std.file;

struct App{
	string[] files;
	int currline = 0;

	void changeDir(const string dir){
		if (!dir.isDir) return;

		clear;
		dir.chdir;
		files = dirEntries("", SpanMode.shallow).array.to!(string[]);
		drawFiles;
		currline = 0;
		changeCurrLine(0);
	}
	
	void changeCurrLine(int diff){
		if ((currline+diff < 0) || (currline+diff >= files.length)) return;
		// reset current line
		foreach(i, t; files[currline]) setCell(1+cast(int)i, 1+currline, t, files[currline].getColor, Color.basic);
		currline += diff;
		// highlight new line
		foreach(i, t; files[currline]) setCell(1+cast(int)i, 1+currline, t, Color.black, files[currline].getColor);
		flush;
	}

	// add text at the top leaving a border of 1 
	void drawFiles() {
		auto trunc = files.take(height-2).map!(a => a.take(width-2)).array.to!(string[]);
		foreach (j, line; trunc) {
			auto color = line.getColor;
			foreach (i, t; line) setCell(1+cast(int)i, 1+cast(int)j, t, color, Color.basic);
		}
		flush;
	}

}

ushort getColor(string filename){
	if (filename.isDir) return Color.blue;
	else if (filename.isFile) return Color.white;
	else return Color.yellow;
}

void main()
{
	init;

	App main;
	main.changeDir(".");

	Event e;
	do {
		pollEvent(&e);
		switch(e.key){
			case Key.arrowUp: main.changeCurrLine(-1); break;
			case Key.arrowDown: main.changeCurrLine(1); break;
			case Key.arrowLeft: main.changeDir(".."); break;
			case Key.arrowRight: main.changeDir(main.files[main.currline]); break;
			default: break;
		}
	} while (e.key != Key.esc);

	shutdown;
}
