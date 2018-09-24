import termbox;
import std.range, std.algorithm;
import std.conv;
import std.file, std.path, std.process;
import std.stdio;

struct App{
	string[] files;
	int currline = 0;

	@property currSel() { return files[currline]; }

	void changeDir(const string dir){
		if (!dir.isDir) return;
		string prevdir = getcwd.baseName;

		clear;
		dir.chdir;
		foreach (i, t; "pwd: "~getcwd) setCell(cast(int)i, 1, t, Color.white|Attribute.underline, Color.basic); // print curr dir
		files = dirEntries("", SpanMode.shallow).array.to!(string[]);
		drawFiles;
		if (dir == "..") currline = to!int(countUntil(files, prevdir));
		else currline = 0;
		changeCurrLine(0);
	}
	
	void changeCurrLine(int diff){
		if ((currline+diff < 0) || (currline+diff >= files.length)) return;
		// reset current line
		foreach(i, t; files[currline]) setCell(1+cast(int)i, 3+currline, t, files[currline].getColor, Color.basic);
		currline += diff;
		// highlight new line
		foreach(i, t; files[currline]) setCell(1+cast(int)i, 3+currline, t, files[currline].getColor|Attribute.reverse, Color.basic|Attribute.reverse);
		flush;
	}

	// add text at the top leaving a border of 1 
	void drawFiles(){
		auto trunc = files.take(height-2).map!(a => a.take(width-2)).array.to!(string[]);
		foreach (j, line; trunc) {
			auto color = line.getColor;
			foreach (i, t; line) setCell(1+cast(int)i, 3+cast(int)j, t, color, Color.basic);
		}
		flush;
	}

	void searchCurrentFiles(){
		// call external fuzzy finder
		auto ff = executeShell("ls | dmenu -i -b -l 10 -p /");
		changeCurrLine(cast(int)countUntil(files, ff.output.strip('\n')) - currline);
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
	io: do {
		pollEvent(&e);
		switch(e.key){
			case Key.esc: break io;
			case Key.arrowUp: main.changeCurrLine(-1); continue;
			case Key.arrowDown: main.changeCurrLine(1); continue;
			case Key.arrowLeft: main.changeDir(".."); continue;
			case Key.arrowRight: main.changeDir(main.currSel); continue;
			case Key.enter: shutdown; writeln(buildPath(getcwd, main.currSel)); return;
			default: break;
		}
		switch(e.ch){
			case '/': main.searchCurrentFiles; break;
			default: break;
		}
	} while (true);

	shutdown;
}
