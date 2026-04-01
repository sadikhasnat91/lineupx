/// App-wide string constants for LineupX.
class AppStrings {
  AppStrings._();

  static const String appName = 'LineupX';
  static const String tagline = 'Build Your Dream XI';
  static const String taglineSub = 'Tactics • Squads • Football Manager';

  // Home
  static const String createNewLineup = 'Create New Lineup';
  static const String savedLineups = 'Saved Lineups';
  static const String managerMode = 'Manager Mode';
  static const String templates = 'Templates';
  static const String quickStart = 'Quick Start';

  // Formation
  static const String selectFormation = 'Select Formation';
  static const String customFormation = 'Custom Formation';
  static const String formationPreview = 'Formation Preview';

  // Lineup builder
  static const String lineupBuilder = 'Lineup Builder';
  static const String addPlayer = 'Add Player';
  static const String removePlayer = 'Remove Player';
  static const String setCaptain = 'Set as Captain';
  static const String setViceCaptain = 'Set as Vice Captain';
  static const String clearSlot = 'Clear Slot';
  static const String bench = 'BENCH';
  static const String addBenchPlayer = 'Add to Bench';
  static const String saveLineup = 'Save Lineup';
  static const String exportLineup = 'Export';
  static const String shareLineup = 'Share';

  // Player selection
  static const String selectPlayer = 'Select Player';
  static const String searchPlayers = 'Search players...';
  static const String filterByClub = 'Club';
  static const String filterByCountry = 'Country';
  static const String filterByRating = 'Rating';
  static const String sortByRating = 'Sort by Rating';
  static const String allClubs = 'All Clubs';
  static const String allCountries = 'All Countries';
  static const String noPlayersFound = 'No players found';
  static const String loadingPlayers = 'Loading players...';

  // Manager mode
  static const String managerModeTitle = 'Manager Mode';
  static const String startingXI = 'Starting XI';
  static const String benchPlayers = 'Bench';
  static const String teamTactics = 'Team Tactics';
  static const String captainSelection = 'Captain';
  static const String viceCaptainSelection = 'Vice Captain';
  static const String teamChemistry = 'Chemistry';
  static const String avgRating = 'Avg Rating';

  // Tactics
  static const String attackStyle = 'Attack Style';
  static const String defensiveStyle = 'Defensive Style';
  static const String defensiveLine = 'Defensive Line';
  static const String width = 'Width';

  static const List<String> attackStyleOptions = [
    'Possession',
    'Counter',
    'Long Ball'
  ];
  static const List<String> defStyleOptions = [
    'High Press',
    'Balanced',
    'Deep Block'
  ];
  static const List<String> defLineOptions = ['High', 'Medium', 'Low'];
  static const List<String> widthOptions = ['Narrow', 'Balanced', 'Wide'];

  // Customization
  static const String teamCustomization = 'Customize Team';
  static const String teamName = 'Team Name';
  static const String teamLogo = 'Team Logo';
  static const String primaryColor = 'Primary Color';
  static const String secondaryColor = 'Secondary Color';
  static const String changeLogo = 'Change Logo';

  // Saved lineups
  static const String savedLineupsTitle = 'Saved Lineups';
  static const String noSavedLineups = 'No saved lineups yet';
  static const String deleteLineup = 'Delete';
  static const String editLineup = 'Edit';
  static const String lineupDeleted = 'Lineup deleted';

  // Errors / messages
  static const String somethingWentWrong = 'Something went wrong';
  static const String lineupSaved = 'Lineup saved successfully!';
  static const String enterTeamName = 'Enter a team name';
  static const String firebaseNotConfigured =
      'Firebase not configured – showing demo data';
}
