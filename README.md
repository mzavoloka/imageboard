Non-anonymous imageboard written in Perl. It has voting system and admin tools.

Works with:
1) Apache
2) PostgreSQL
3) Wendy Web Framework (https://github.com/gnudist/wendy)
4) LittleORM (https://github.com/gnudist/littleorm)

You can check out it's functionality at http://imageboard.mzavoloka.ru

Admin tools are available for user 'admin', password 'admin'. Also, this user can edit or delete threads/messages, ban users. In admin tools admin can edit forum constants such as, for example, maximum image file size or session expiration time, edit user profiles (feature in development), edit permissions of other users (feature in development).
There is another special user 'moderator', password 'moderator'. This user has same permissions as admin except of access to admin tools.