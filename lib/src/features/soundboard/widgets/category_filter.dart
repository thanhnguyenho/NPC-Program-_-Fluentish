import 'package:flutter/material.dart';


class CategoryFilter extends StatelessWidget {
 const CategoryFilter({super.key});


 @override
 Widget build(BuildContext context) {
   final categories = [
     {'icon': Icons.mic_none, 'label': 'All Words'},
     {'icon': Icons.star_border, 'label': 'Favourites'},
     {'icon': Icons.translate, 'label': 'Common Words'},
     {'icon': Icons.waving_hand_outlined, 'label': 'Greetings'},
     {'icon': Icons.numbers, 'label': 'Numbers'},
     {'icon': Icons.restaurant_outlined, 'label': 'Food'},
     {'icon': Icons.shopping_cart_outlined, 'label': 'Shopping'},
     {'icon': Icons.flight_takeoff, 'label': 'Travel'},
     {'icon': Icons.local_hospital_outlined, 'label': 'Emergency'},
   ];


   return SizedBox(
     height: 45,
     child: ListView.separated(
       scrollDirection: Axis.horizontal,
       itemCount: categories.length,
       separatorBuilder: (_, __) => const SizedBox(width: 10),
       itemBuilder: (context, index) {
         final category = categories[index];


         final bool selected = index == 0;


         return Container(
           padding: const EdgeInsets.symmetric(
             horizontal: 16,
             vertical: 10,
           ),
           decoration: BoxDecoration(
             color: selected
                 ? const Color(0xFF4E5A45)
                 : const Color(0xFF868F54),
             borderRadius: BorderRadius.circular(10),
           ),
           child: Row(
             children: [
               Icon(
                 category['icon'] as IconData,
                 color: Colors.white,
                 size: 18,
               ),
               const SizedBox(width: 8),
               Text(
                 category['label'] as String,
                 style: const TextStyle(
                   color: Colors.white,
                   fontWeight: FontWeight.w600,
                 ),
               ),
             ],
           ),
         );
       },
     ),
   );
 }
}

