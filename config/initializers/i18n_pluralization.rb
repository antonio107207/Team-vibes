require "i18n/backend/pluralization"
I18n::Backend::Simple.include I18n::Backend::Pluralization

UK_PLURAL_RULE = lambda { |n|
  mod10  = n.abs % 10
  mod100 = n.abs % 100
  if    mod10 == 1 && mod100 != 11                                     then :one
  elsif [2, 3, 4].include?(mod10) && ![12, 13, 14].include?(mod100)   then :few
  elsif mod10 == 0 || (5..9).cover?(mod10) || (11..14).cover?(mod100) then :many
  else :other
  end
}
EN_PLURAL_RULE = lambda { |n| n.abs == 1 ? :one : :other }

def store_plural_rules
  I18n.backend.store_translations :uk, i18n: { plural: { rule: UK_PLURAL_RULE } }
  I18n.backend.store_translations :en, i18n: { plural: { rule: EN_PLURAL_RULE } }
end

# Store now and after every I18n.reload! (which clears translations)
store_plural_rules
I18n.backend.class.prepend(Module.new do
  def reload!
    super
    store_plural_rules
  end
end)
