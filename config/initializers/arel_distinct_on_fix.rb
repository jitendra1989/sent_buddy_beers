# See ticket https://rails.lighthouseapp.com/projects/8994/tickets/6450 for details
class Arel::Visitors::PostgreSQL
  def visit_Arel_Nodes_SelectStatement o
    super
  end
end
