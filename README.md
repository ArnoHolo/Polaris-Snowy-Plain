# Polaris Snowy Plain

Ruby script for a RPG Maker XP project.

It allows the player to walk in a 3D-like FPS view. The player can move forward and backwards with UP and DOWN arrows, and can change of directions with LEFT and RIGHT arrows.

The "map" is just a disk with an outer limit, at the center of which is located a scientific base called Polaris. This is the goal of the player. The base is just a smaller disk on which the player cannot walk through.

## Usage

You need to have RPG Maker XP on your computer to use this script. In the Script editor (F11), insert a new line in Materials section, give it a name, and paste the content of lib/polaris_snowy_plain.rb.

To use it in a RPG Maker XP event, use `Insert a script` command and write `snowy_plain_initialize` in an event launched automatically. You should delete this event just after that.

In a parallel event, insert a script with `snowy_plain_key_entered`, after the previous event is called.

In a condition, test for `snowy_plain_base_found?` to check if player is in front the base (near the center of the disk).

Script tested with Ruby 2.0.0p648 even if RPG Maker XP uses Ruby 1.8.1.

## Running the tests

RSpec is used for unit test. Use `rspec` command in Terminal to run the tests.

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

## License

This project is licensed under the MIT License. Well... I think so.