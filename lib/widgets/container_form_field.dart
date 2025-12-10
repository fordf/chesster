import 'package:flutter/material.dart';

class ContainerFormField<W extends Widget, T> extends FormField<T> {
  final Color errorColor;
  final W Function({
    Key? key,
    required void Function(T value) onChanged,
    required T? value,
  }) child;
  ContainerFormField({
    super.key,
    required this.child,
    required this.errorColor,
    FormFieldValidator<T>? validator,
    super.onSaved,
  }) : super(
          validator: validator,
          builder: (field) {
            void onChangedHandler(T? value) {
              field.didChange(value);
            }

            bool isError = !(!field.hasError || field.isValid);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: isError
                      ? BoxDecoration(
                          border: Border.all(color: errorColor),
                          borderRadius: BorderRadius.circular(58),
                        )
                      : null,
                  child: child(
                    onChanged: onChangedHandler,
                    value: field.value,
                  ),
                ),
                isError
                    ? Text(
                        field.errorText ?? "",
                        style: TextStyle(
                          color: errorColor,
                          fontSize: 13.0,
                        ),
                      )
                    : const SizedBox(
                        height: 22,
                      )
              ],
            );
          },
        );

  @override
  FormFieldState<T> createState() => FormFieldState<T>();
}
