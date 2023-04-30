package;

class LockManager {
	public static var allSongs = [
		"forest-fire",
		"spectral-sonnet",
		"spectral-sonnet-beta",
		"goated",
		"after-dark",
		"mansion-match",
		"candlelit-clash",
		"goat-remake",
		"interrupted",
		"all-saints-scramble",
		"spooks",
		"heart-attack",
		"jelly-jamboree",
		"minimize",
		"pasta-night",
	];

	public static var lockedSongs = [
		"heart-attack",
		"pasta-night",
		"jelly-jamboree",
	];

	public static var lastUnlocked:Array<String> = [];

	public static function precheckLastUnlock() {
		lastUnlocked = getUnlockedSongs();
	}

	public static function getNewlyUnlockedSongs() {
		//lastUnlocked = getUnlockedSongs();
		var curUnlocked = getUnlockedSongs();
		var unlocked = [];
		for(song in curUnlocked) {
			if(!lastUnlocked.contains(song)) {
				unlocked.push(song);
			}
		}
		precheckLastUnlock();
		return unlocked;
	}

	static function getUnlockedSongs() {
		var unlocked = [];
		for(song in lockedSongs) {
			if(isSongUnlocked(song)) {
				unlocked.push(song);
			}
		}
		return unlocked;
	}

	public static function isSongUnlocked(song:String) {
		song = Paths.formatToSongPath(song);
		return switch(song) {
			case "pasta-night" | "heart-attack" | "jelly-jamboree":
				for(sng in allSongs) {
					if(!lockedSongs.contains(sng)) {
						if(!hasBeaten(sng)) {
							//trace(song, sng);
							return false;
						}
					}
				}

				return true;
			default: true;
		}
	}

	public static function hasBeaten(song:String, diff:Int = -1) {
		song = Paths.formatToSongPath(song);
		var diffs = ["-easy", "", "-hard", "-ex"];

		if(diff == -1) {
			for(d in diffs) {
				if(Highscore.songScores.get(song + d) > 0) {
					return true;
				}
			}
			return false;
		}
		var score = Highscore.getScore(song, diff) > 0;
		return score;
	}
}